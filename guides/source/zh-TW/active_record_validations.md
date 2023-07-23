**DO NOT READ THIS FILE ON GITHUB, GUIDES ARE PUBLISHED ON https://guides.rubyonrails.org.**, original file md5: 37dd3507f05f7787a794868a2619e6d5
Active Record 驗證
==================

本指南教你如何使用 Active Record 的驗證功能，在將物件存入資料庫之前驗證其狀態。

閱讀完本指南後，你將會了解：

* 如何使用內建的 Active Record 驗證輔助方法。
* 如何建立自訂的驗證方法。
* 如何處理驗證過程產生的錯誤訊息。

--------------------------------------------------------------------------------

驗證概述
--------

以下是一個非常簡單的驗證範例：

```ruby
class Person < ApplicationRecord
  validates :name, presence: true
end
```

```irb
irb> Person.create(name: "John Doe").valid?
=> true
irb> Person.create(name: nil).valid?
=> false
```

如你所見，我們的驗證讓我們知道沒有 `name` 屬性的 `Person` 是無效的。第二個 `Person` 將不會被持久化到資料庫中。

在深入研究更多細節之前，讓我們先談談驗證如何融入應用程式的整體架構。

### 為何使用驗證？

驗證用於確保只有有效的資料被儲存到資料庫中。例如，對於你的應用程式來說，確保每個使用者提供有效的電子郵件地址和郵寄地址可能很重要。模型層的驗證是確保只有有效的資料被儲存到資料庫中的最佳方式。它們與資料庫無關，無法被最終使用者繞過，且方便進行測試和維護。Rails 提供了內建的輔助方法來滿足常見需求，同時也允許你建立自己的驗證方法。

在將資料儲存到資料庫之前，還有其他幾種驗證資料的方式，包括原生資料庫約束、客戶端驗證和控制器層驗證。以下是這些方式的優缺點摘要：

* 資料庫約束和/或儲存過程使驗證機制與資料庫相依，並可能使測試和維護變得更加困難。然而，如果你的資料庫被其他應用程式使用，使用一些資料庫層約束可能是個好主意。此外，資料庫層驗證可以安全地處理一些其他方式難以實現的事情（例如在使用頻繁的表中的唯一性）。
* 客戶端驗證可能有用，但如果單獨使用通常不可靠。如果使用 JavaScript 實現，如果使用者的瀏覽器關閉了 JavaScript，則可能會被繞過。然而，如果與其他技術結合使用，客戶端驗證可以是一種提供使用者即時反饋的便捷方式。
* 控制器層驗證可能很誘人，但往往變得難以控制和維護。在可能的情況下，保持控制器簡單是一個好主意，這將使你的應用程式在長期運行中更加愉快。

在特定情況下選擇這些方式。Rails 團隊認為，在大多數情況下，模型層驗證是最適合的方式。

### 何時進行驗證？

Active Record 物件分為兩種：對應資料庫內的一行的物件和不對應資料庫的物件。當你創建一個新物件時，例如使用 `new` 方法，該物件尚未屬於資料庫。一旦你對該物件調用 `save` 方法，它將被儲存到適當的資料庫表中。Active Record 使用 `new_record?` 實例方法來判斷物件是否已經存在於資料庫中。考慮以下 Active Record 類：

```ruby
class Person < ApplicationRecord
end
```

我們可以通過觀察一些 `bin/rails console` 的輸出來了解它的運作方式：

```irb
irb> p = Person.new(name: "John Doe")
=> #<Person id: nil, name: "John Doe", created_at: nil, updated_at: nil>

irb> p.new_record?
=> true

irb> p.save
=> true

irb> p.new_record?
=> false
```

創建並保存一個新記錄將向資料庫發送一個 SQL `INSERT` 操作。更新現有記錄將發送一個 SQL `UPDATE` 操作。通常在這些命令發送到資料庫之前運行驗證。如果任何驗證失敗，該物件將被標記為無效，Active Record 將不執行 `INSERT` 或 `UPDATE` 操作。這樣可以避免將無效的物件存儲到資料庫中。你可以選擇在物件創建、保存或更新時運行特定的驗證。

注意：有很多方法可以改變資料庫中物件的狀態。有些方法會觸發驗證，但有些方法則不會。這意味著如果不小心的話，有可能在資料庫中保存一個無效的物件。
以下方法會觸發驗證，只有在物件有效時才會將物件保存到資料庫中：

* `create`
* `create!`
* `save`
* `save!`
* `update`
* `update!`

感嘆號版本（例如 `save!`）會在記錄無效時引發異常。非感嘆號版本則不會：`save` 和 `update` 返回 `false`，而 `create` 返回物件本身。

### 跳過驗證

以下方法會跳過驗證，無論物件是否有效，都會將物件保存到資料庫中。請謹慎使用這些方法。

* `decrement!`
* `decrement_counter`
* `increment!`
* `increment_counter`
* `insert`
* `insert!`
* `insert_all`
* `insert_all!`
* `toggle!`
* `touch`
* `touch_all`
* `update_all`
* `update_attribute`
* `update_column`
* `update_columns`
* `update_counters`
* `upsert`
* `upsert_all`

請注意，如果將 `validate: false` 作為參數傳遞給 `save`，它也可以跳過驗證。請謹慎使用此技巧。

* `save(validate: false)`

### `valid?` 和 `invalid?`

在保存 Active Record 物件之前，Rails 會運行驗證。如果這些驗證產生任何錯誤，Rails 就不會保存該物件。

您也可以自行運行這些驗證。[`valid?`][] 會觸發驗證並返回 true（如果物件中沒有錯誤），否則返回 false。如上所示：

```ruby
class Person < ApplicationRecord
  validates :name, presence: true
end
```

```irb
irb> Person.create(name: "John Doe").valid?
=> true
irb> Person.create(name: nil).valid?
=> false
```

在 Active Record 執行驗證之後，任何失敗都可以通過 [`errors`][] 實例方法訪問，該方法返回一個錯誤集合。根據定義，如果在運行驗證後此集合為空，則物件有效。

請注意，使用 `new` 實例化的物件即使在技術上無效，也不會報告錯誤，因為驗證只有在保存物件時才會自動運行，例如使用 `create` 或 `save` 方法。

```ruby
class Person < ApplicationRecord
  validates :name, presence: true
end
```

```irb
irb> p = Person.new
=> #<Person id: nil, name: nil>
irb> p.errors.size
=> 0

irb> p.valid?
=> false
irb> p.errors.objects.first.full_message
=> "Name can’t be blank"

irb> p = Person.create
=> #<Person id: nil, name: nil>
irb> p.errors.objects.first.full_message
=> "Name can’t be blank"

irb> p.save
=> false

irb> p.save!
ActiveRecord::RecordInvalid: Validation failed: Name can’t be blank

irb> Person.create!
ActiveRecord::RecordInvalid: Validation failed: Name can’t be blank
```

[`invalid?`][] 是 `valid?` 的相反。它觸發驗證，如果物件中存在任何錯誤，則返回 true，否則返回 false。


### `errors[]`

要驗證物件的特定屬性是否有效，可以使用 [`errors[:attribute]`][Errors#squarebrackets]。它返回 `:attribute` 的所有錯誤訊息的陣列。如果指定的屬性上沒有錯誤，則返回一個空陣列。

此方法只在運行驗證之後才有用，因為它只檢查錯誤集合，並且不觸發驗證本身。它與上面解釋的 `ActiveRecord::Base#invalid?` 方法不同，因為它不會驗證整個物件的有效性。它只檢查物件的個別屬性上是否存在錯誤。

```ruby
class Person < ApplicationRecord
  validates :name, presence: true
end
```

```irb
irb> Person.new.errors[:name].any?
=> false
irb> Person.create.errors[:name].any?
=> true
```

我們將在 [處理驗證錯誤](#working-with-validation-errors) 章節中更深入地介紹驗證錯誤。


驗證輔助方法
------------

Active Record 提供了許多預定義的驗證輔助方法，您可以直接在類定義中使用這些輔助方法。這些輔助方法提供常見的驗證規則。每次驗證失敗時，都會將錯誤添加到物件的 `errors` 集合中，並與正在驗證的屬性關聯起來。

每個輔助方法都接受任意數量的屬性名稱，因此只需一行代碼，就可以將相同類型的驗證添加到多個屬性中。

它們都接受 `:on` 和 `:message` 選項，這些選項分別定義驗證應該在何時運行以及如果驗證失敗時應該將什麼訊息添加到 `errors` 集合中。`:on` 選項接受 `:create` 或 `:update` 的值。每個驗證輔助方法都有一個預設的錯誤訊息。當未指定 `:message` 選項時，將使用這些訊息。讓我們來看看每個可用的輔助方法。

INFO: 要查看可用的預設輔助方法列表，請參閱 [`ActiveModel::Validations::HelperMethods`][]。
### `接受`

此方法用於驗證在提交表單時，用戶界面上的複選框是否被選中。通常在用戶需要同意應用程式的服務條款、確認已閱讀某些文字或類似概念時使用。

```ruby
class Person < ApplicationRecord
  validates :terms_of_service, acceptance: true
end
```

只有在 `terms_of_service` 不為 `nil` 時才執行此檢查。
此輔助方法的默認錯誤訊息為 _"必須被接受"_。
您也可以通過 `message` 選項傳遞自定義訊息。

```ruby
class Person < ApplicationRecord
  validates :terms_of_service, acceptance: { message: '必須遵守' }
end
```

它還可以接收一個 `:accept` 選項，用於指定被視為可接受的允許值。默認為 `['1', true]`，並且可以輕鬆更改。

```ruby
class Person < ApplicationRecord
  validates :terms_of_service, acceptance: { accept: 'yes' }
  validates :eula, acceptance: { accept: ['TRUE', 'accepted'] }
end
```

此驗證非常特定於 Web 應用程式，並且此 'acceptance' 不需要在數據庫中記錄任何地方。如果您沒有相應的字段，輔助方法將創建一個虛擬屬性。如果字段確實存在於數據庫中，則 `accept` 選項必須設置為或包含 `true`，否則驗證將不運行。

### `確認`

當您有兩個文本字段應該接收完全相同的內容時，應使用此輔助方法。例如，您可能希望確認電子郵件地址或密碼。此驗證將創建一個虛擬屬性，其名稱是需要通過附加 "_confirmation" 來確認的字段的名稱。

```ruby
class Person < ApplicationRecord
  validates :email, confirmation: true
end
```

在您的視圖模板中，您可以使用以下代碼：

```erb
<%= text_field :person, :email %>
<%= text_field :person, :email_confirmation %>
```

注意：只有在 `email_confirmation` 不為 `nil` 時才執行此檢查。要求確認，請確保為確認屬性添加存在檢查（稍後在本指南中將介紹 `presence`）：

```ruby
class Person < ApplicationRecord
  validates :email, confirmation: true
  validates :email_confirmation, presence: true
end
```

還有一個 `:case_sensitive` 選項，您可以使用它來定義確認約束是否區分大小寫。此選項的默認值為 true。

```ruby
class Person < ApplicationRecord
  validates :email, confirmation: { case_sensitive: false }
end
```

此輔助方法的默認錯誤訊息為 _"與確認不匹配"_。
您也可以通過 `message` 選項傳遞自定義訊息。

通常，在使用此驗證程序時，您會希望將其與 `:if` 選項結合使用，以僅在初始字段更改時驗證 "_confirmation" 字段，而不是每次保存記錄時都驗證。稍後將介紹更多關於[條件驗證](#conditional-validation)的內容。

```ruby
class Person < ApplicationRecord
  validates :email, confirmation: true
  validates :email_confirmation, presence: true, if: :email_changed?
end
```

### `比較`

此檢查將驗證兩個可比較值之間的比較。

```ruby
class Promotion < ApplicationRecord
  validates :end_date, comparison: { greater_than: :start_date }
end
```

此輔助方法的默認錯誤訊息為 _"比較失敗"_。
您也可以通過 `message` 選項傳遞自定義訊息。

支援以下選項：

* `:greater_than` - 指定值必須大於提供的值。此選項的默認錯誤訊息為 _"必須大於 %{count}"_。
* `:greater_than_or_equal_to` - 指定值必須大於或等於提供的值。此選項的默認錯誤訊息為 _"必須大於或等於 %{count}"_。
* `:equal_to` - 指定值必須等於提供的值。此選項的默認錯誤訊息為 _"必須等於 %{count}"_。
* `:less_than` - 指定值必須小於提供的值。此選項的默認錯誤訊息為 _"必須小於 %{count}"_。
* `:less_than_or_equal_to` - 指定值必須小於或等於提供的值。此選項的默認錯誤訊息為 _"必須小於或等於 %{count}"_。
* `:other_than` - 指定值必須不等於提供的值。此選項的默認錯誤訊息為 _"必須不等於 %{count}"_。

注意：驗證器需要提供比較選項。每個選項都接受值、proc 或符號。任何包含 Comparable 的類都可以進行比較。
### `格式`

這個輔助工具通過測試屬性的值是否與給定的正則表達式匹配來驗證屬性的值，這個正則表達式是使用 `:with` 選項指定的。

```ruby
class Product < ApplicationRecord
  validates :legacy_code, format: { with: /\A[a-zA-Z]+\z/,
    message: "只允許字母" }
end
```

相反地，使用 `:without` 選項，您可以要求指定的屬性 _不_ 與正則表達式匹配。

無論哪種情況，提供的 `:with` 或 `:without` 選項必須是一個正則表達式或返回正則表達式的 proc 或 lambda。

默認的錯誤消息是 _"無效"_。

警告：使用 `\A` 和 `\z` 來匹配字符串的開頭和結尾，`^` 和 `$` 匹配行的開頭/結尾。由於 `^` 和 `$` 的常見誤用，如果您在提供的正則表達式中使用這兩個錨點之一，則需要傳遞 `multiline: true` 選項。在大多數情況下，您應該使用 `\A` 和 `\z`。

### `包含`

這個輔助工具驗證屬性的值是否包含在給定的集合中。實際上，這個集合可以是任何可枚舉的對象。

```ruby
class Coffee < ApplicationRecord
  validates :size, inclusion: { in: %w(small medium large),
    message: "%{value} 不是有效的尺寸" }
end
```

`inclusion` 輔助工具有一個 `:in` 選項，接受將被接受的值的集合。`:in` 選項有一個別名叫做 `:within`，如果您喜歡，也可以使用它來達到同樣的目的。上面的例子使用了 `:message` 選項，以展示如何包含屬性的值。有關完整選項，請參閱[消息文檔](#message)。

這個輔助工具的默認錯誤消息是 _"不在列表中"_。

### `排除`

`包含` 的相反是... `排除`！

這個輔助工具驗證屬性的值是否不包含在給定的集合中。實際上，這個集合可以是任何可枚舉的對象。

```ruby
class Account < ApplicationRecord
  validates :subdomain, exclusion: { in: %w(www us ca jp),
    message: "%{value} 是保留的。" }
end
```

`exclusion` 輔助工具有一個 `:in` 選項，接受將不被接受的值的集合。`:in` 選項有一個別名叫做 `:within`，如果您喜歡，也可以使用它來達到同樣的目的。這個例子使用了 `:message` 選項，以展示如何包含屬性的值。有關消息參數的完整選項，請參閱[消息文檔](#message)。

默認的錯誤消息是 _"是保留的"_。

除了傳統的可枚舉對象（如數組），您還可以提供一個返回可枚舉對象的 proc、lambda 或符號。如果可枚舉對象是數值、時間或日期時間範圍，則使用 `Range#cover?` 進行測試，否則使用 `include?`。使用 proc 或 lambda 時，驗證的實例將作為參數傳遞。

### `長度`

這個輔助工具驗證屬性的值的長度。它提供了多種選項，所以您可以以不同的方式指定長度限制：

```ruby
class Person < ApplicationRecord
  validates :name, length: { minimum: 2 }
  validates :bio, length: { maximum: 500 }
  validates :password, length: { in: 6..20 }
  validates :registration_number, length: { is: 6 }
end
```

可能的長度限制選項有：

* `:minimum` - 屬性的長度不能少於指定的長度。
* `:maximum` - 屬性的長度不能超過指定的長度。
* `:in`（或 `:within`）- 屬性的長度必須包含在給定的區間內。這個選項的值必須是一個範圍。
* `:is` - 屬性的長度必須等於給定的值。

默認的錯誤消息取決於正在執行的長度驗證的類型。您可以使用 `:wrong_length`、`:too_long` 和 `:too_short` 選項以及 `%{count}` 作為長度限制對應的數字的佔位符來自定義這些消息。您仍然可以使用 `:message` 選項來指定錯誤消息。

```ruby
class Person < ApplicationRecord
  validates :bio, length: { maximum: 1000,
    too_long: "最多允許 %{count} 個字符" }
end
```

請注意，默認的錯誤消息是複數的（例如，"太短（最少 %{count} 個字符）"）。因此，當 `:minimum` 為 1 時，您應該提供自定義消息或使用 `presence: true`。當 `:in` 或 `:within` 的下限為 1 時，您應該提供自定義消息或在 `length` 之前調用 `presence`。
注意：除了可以同时使用“：minimum”和“：maximum”选项之外，一次只能使用一个约束选项。

### `numericality`

此助手验证属性只包含数字值。默认情况下，它将匹配一个可选的符号，后面跟着一个整数或浮点数。

要指定只允许整数，将“：only_integer”设置为true。然后它将使用以下正则表达式验证属性的值。

```ruby
/\A[+-]?\d+\z/
```

否则，它将尝试使用`Float`将值转换为数字。`Float`将使用列的精度值或最多15位数字转换为`BigDecimal`。

```ruby
class Player < ApplicationRecord
  validates :points, numericality: true
  validates :games_played, numericality: { only_integer: true }
end
```

“：only_integer”的默认错误消息为“必须是整数”。

除了“：only_integer”之外，此助手还接受“：only_numeric”选项，该选项指定值必须是`Numeric`的实例，并尝试解析该值（如果它是`String`）。

注意：默认情况下，`numericality`不允许`nil`值。您可以使用“allow_nil: true”选项来允许它。请注意，对于`Integer`和`Float`列，空字符串将转换为`nil`。

当未指定选项时，“is not a number”的默认错误消息为“不是数字”。

还有许多选项可用于添加约束到可接受的值：

* `:greater_than` - 指定值必须大于提供的值。此选项的默认错误消息为“必须大于%{count}”。
* `:greater_than_or_equal_to` - 指定值必须大于或等于提供的值。此选项的默认错误消息为“必须大于或等于%{count}”。
* `:equal_to` - 指定值必须等于提供的值。此选项的默认错误消息为“必须等于%{count}”。
* `:less_than` - 指定值必须小于提供的值。此选项的默认错误消息为“必须小于%{count}”。
* `:less_than_or_equal_to` - 指定值必须小于或等于提供的值。此选项的默认错误消息为“必须小于或等于%{count}”。
* `:other_than` - 指定值必须不等于提供的值。此选项的默认错误消息为“必须不等于%{count}”。
* `:in` - 指定值必须在提供的范围内。此选项的默认错误消息为“必须在%{count}”。
* `:odd` - 指定值必须是奇数。此选项的默认错误消息为“必须是奇数”。
* `:even` - 指定值必须是偶数。此选项的默认错误消息为“必须是偶数”。

### `presence`

此助手验证指定的属性不为空。它使用[`Object#blank?`][]方法来检查值是否为`nil`或空字符串，即空字符串或仅包含空格的字符串。

```ruby
class Person < ApplicationRecord
  validates :name, :login, :email, presence: true
end
```

如果要确保关联存在，您需要测试关联对象本身是否存在，而不是用于映射关联的外键。这样，不仅检查外键是否为空，还检查引用的对象是否存在。

```ruby
class Supplier < ApplicationRecord
  has_one :account
  validates :account, presence: true
end
```

为了验证需要存在的关联记录，必须为关联指定`：inverse_of`选项：

```ruby
class Order < ApplicationRecord
  has_many :line_items, inverse_of: :order
end
```

注意：如果要确保关联既存在又有效，还需要使用`validates_associated`。更多信息请参见下文。

如果验证通过`has_one`或`has_many`关系关联的对象的存在，则会检查对象既不是`blank?`也不是`marked_for_destruction?`。

由于`false.blank?`为true，如果要验证布尔字段的存在，请使用以下验证之一：

```ruby
# 值必须为true或false
validates :boolean_field_name, inclusion: [true, false]
# 值不能为nil，即true或false
validates :boolean_field_name, exclusion: [nil]
```
使用其中一個驗證方法，您將確保值不會為`nil`，這在大多數情況下會導致`NULL`值。

默認的錯誤消息是_"不能為空"_。

### `absence`

此輔助方法驗證指定的屬性是否不存在。它使用[`Object#present?`][]方法來檢查值是否不是`nil`或空字符串，即空字符串或只包含空格的字符串。

```ruby
class Person < ApplicationRecord
  validates :name, :login, :email, absence: true
end
```

如果您想確保關聯不存在，您需要測試關聯對象本身是否不存在，而不是用於映射關聯的外鍵。

```ruby
class LineItem < ApplicationRecord
  belongs_to :order
  validates :order, absence: true
end
```

為了驗證需要不存在的關聯記錄，您必須為關聯指定`:inverse_of`選項：

```ruby
class Order < ApplicationRecord
  has_many :line_items, inverse_of: :order
end
```

注意：如果您要確保關聯既存在又有效，您還需要使用`validates_associated`。更多信息參見下文。

如果您驗證一個通過`has_one`或`has_many`關聯關聯的對象不存在，它將檢查該對象既不是`present?`也不是`marked_for_destruction?`。

由於`false.present?`為false，如果您要驗證布爾字段的不存在，您應該使用`validates :field_name, exclusion: { in: [true, false] }`。

默認的錯誤消息是_"必須為空"_。

### `uniqueness`

此輔助方法驗證屬性的值在對象保存之前是唯一的。

```ruby
class Account < ApplicationRecord
  validates :email, uniqueness: true
end
```

通過對模型的表執行SQL查詢來進行驗證，搜索具有相同值的現有記錄。

您可以使用`:scope`選項來指定用於限制唯一性檢查的一個或多個屬性：

```ruby
class Holiday < ApplicationRecord
  validates :name, uniqueness: { scope: :year,
    message: "每年應該只發生一次" }
end
```

警告：此驗證不會在數據庫中創建唯一性約束，因此可能會發生兩個不同的數據庫連接創建具有相同值的兩個記錄的情況，而您希望該列是唯一的。為了避免這種情況，您必須在數據庫中為該列創建一個唯一索引。

為了在數據庫中添加唯一性約束，請在遷移中使用[`add_index`][]語句，並包含`unique: true`選項。

如果您希望創建一個數據庫約束以防止使用`：scope`選項可能違反唯一性驗證的情況，您必須在數據庫中為兩個列創建一個唯一索引。有關多列索引的更多詳細信息，請參見[MySQL手冊][]，有關引用一組列的唯一約束的示例，請參見[PostgreSQL手冊][]。

還有一個`:case_sensitive`選項，您可以使用它來定義唯一性約束是區分大小寫、不區分大小寫還是遵循默認數據庫排序。此選項默認為遵循默認數據庫排序。

```ruby
class Person < ApplicationRecord
  validates :name, uniqueness: { case_sensitive: false }
end
```

警告：請注意，某些數據庫已配置為執行不區分大小寫的搜索。

您可以使用`:conditions`選項來指定其他條件作為`WHERE` SQL片段，以限制唯一性約束查找（例如`conditions: -> { where(status: 'active') }`）。

默認的錯誤消息是_"已被佔用"_。

有關更多信息，請參見[`validates_uniqueness_of`][]。

[MySQL手冊]: https://dev.mysql.com/doc/refman/en/multiple-column-indexes.html
[PostgreSQL手冊]: https://www.postgresql.org/docs/current/static/ddl-constraints.html

### `validates_associated`

當您的模型具有始終需要驗證的關聯時，應使用此輔助方法。每次嘗試保存對象時，將對每個關聯對象調用`valid?`。

```ruby
class Library < ApplicationRecord
  has_many :books
  validates_associated :books
end
```

此驗證將適用於所有關聯類型。

注意：不要在關聯的兩端都使用`validates_associated`。它們將在無限循環中互相調用。

[`validates_associated`][]的默認錯誤消息是_"無效"。請注意，每個關聯對象都將包含自己的`errors`集合；錯誤不會冒泡到調用模型。

注意：[`validates_associated`][]只能用於ActiveRecord對象，到目前為止，任何包含[`ActiveModel::Validations`][]的對象也可以使用前面提到的方法。
### `validates_each`

這個輔助方法對屬性進行塊驗證。它沒有預定義的驗證函數。您應該使用塊創建一個驗證函數，並將傳遞給[`validates_each`][]的每個屬性都對其進行測試。

在下面的示例中，我們將拒絕以小寫字母開頭的名字和姓氏。

```ruby
class Person < ApplicationRecord
  validates_each :name, :surname do |record, attr, value|
    record.errors.add(attr, '必須以大寫字母開頭') if /\A[[:lower:]]/.match?(value)
  end
end
```

該塊接收記錄、屬性名稱和屬性值。

您可以在塊內進行任何檢查有效數據的操作。如果驗證失敗，您應該向模型添加一個錯誤，從而使其無效。


### `validates_with`

這個輔助方法將記錄傳遞給一個獨立的類進行驗證。

```ruby
class GoodnessValidator < ActiveModel::Validator
  def validate(record)
    if record.first_name == "Evil"
      record.errors.add :base, "這個人是邪惡的"
    end
  end
end

class Person < ApplicationRecord
  validates_with GoodnessValidator
end
```

`validates_with` 沒有默認的錯誤消息。您必須在驗證器類中手動添加錯誤到記錄的錯誤集合中。

注意：添加到 `record.errors[:base]` 的錯誤與記錄作為整體的狀態有關。

要實現 validate 方法，您必須在方法定義中接受一個 `record` 參數，該參數是要驗證的記錄。

如果要在特定屬性上添加錯誤，請將其作為第一個參數傳遞，例如 `record.errors.add(:first_name, "請選擇另一個名字")`。我們稍後將更詳細地介紹[驗證錯誤][]。

```ruby
def validate(record)
  if record.some_field != "acceptable"
    record.errors.add :some_field, "這個字段是不可接受的"
  end
end
```

[`validates_with`][] 輔助方法接受一個類或一個類列表來進行驗證。

```ruby
class Person < ApplicationRecord
  validates_with MyValidator, MyOtherValidator, on: :create
end
```

與所有其他驗證一樣，`validates_with` 接受 `:if`、`:unless` 和 `:on` 選項。如果傳遞任何其他選項，它將將這些選項作為 `options` 發送給驗證器類：

```ruby
class GoodnessValidator < ActiveModel::Validator
  def validate(record)
    if options[:fields].any? { |field| record.send(field) == "Evil" }
      record.errors.add :base, "這個人是邪惡的"
    end
  end
end

class Person < ApplicationRecord
  validates_with GoodnessValidator, fields: [:first_name, :last_name]
end
```

請注意，驗證器將在整個應用程序生命週期中僅初始化一次，而不是在每次驗證運行時初始化，因此在其中使用實例變量時要小心。

如果您的驗證器足夠複雜，需要使用實例變量，您可以輕鬆地使用一個普通的 Ruby 對象：

```ruby
class Person < ApplicationRecord
  validate do |person|
    GoodnessValidator.new(person).validate
  end
end

class GoodnessValidator
  def initialize(person)
    @person = person
  end

  def validate
    if some_complex_condition_involving_ivars_and_private_methods?
      @person.errors.add :base, "這個人是邪惡的"
    end
  end

  # ...
end
```

稍後我們將更詳細地介紹[自定義驗證](#performing-custom-validations)。

[驗證錯誤](#working-with-validation-errors)

常見的驗證選項
-------------------------

我們剛剛介紹的驗證器支持幾個常見的選項，現在讓我們來看看其中一些！

注意：並非所有這些選項都被每個驗證器支持，請參閱[`ActiveModel::Validations`][]的 API 文檔。

使用我們剛剛提到的任何驗證方法，還有一個共享的常見選項列表。我們現在來介紹這些！

* [`:allow_nil`](#allow-nil)：如果屬性為 `nil`，則跳過驗證。
* [`:allow_blank`](#allow-blank)：如果屬性為空，如 `nil` 或空字符串，則跳過驗證。
* [`:message`](#message)：指定自定義錯誤消息。
* [`:on`](#on)：指定此驗證活動的上下文。
* [`:strict`](#strict-validations)：驗證失敗時引發異常。
* [`:if` 和 `:unless`](#conditional-validation)：指定驗證應該發生或不應該發生的條件。


### `:allow_nil`

`：allow_nil` 選項在要驗證的值為 `nil` 時跳過驗證。

```ruby
class Coffee < ApplicationRecord
  validates :size, inclusion: { in: %w(small medium large),
    message: "%{value} 不是有效的尺寸" }, allow_nil: true
end
```

```irb
irb> Coffee.create(size: nil).valid?
=> true
irb> Coffee.create(size: "mega").valid?
=> false
```

有關 message 參數的完整選項，請參閱[消息文檔](#message)。

### `:allow_blank`

`：allow_blank` 選項與 `：allow_nil` 選項類似。此選項將使驗證在屬性的值為 `blank?` 時通過，例如 `nil` 或空字符串。

```ruby
class Topic < ApplicationRecord
  validates :title, length: { is: 5 }, allow_blank: true
end
```

```irb
irb> Topic.create(title: "").valid?
=> true
irb> Topic.create(title: nil).valid?
=> true
```

### `:message`
如您所見，`:message` 選項允許您指定在驗證失敗時將添加到 `errors` 集合中的消息。當未使用此選項時，Active Record 將使用每個驗證助手的相應默認錯誤消息。

`:message` 選項接受 `String` 或 `Proc` 作為其值。

`String` `:message` 值可以選擇性包含 `%{value}`、`%{attribute}` 和 `%{model}` 中的任何/所有內容，這些內容在驗證失敗時將被動態替換。此替換是使用 i18n gem 完成的，並且占位符必須完全匹配，不允許有空格。

```ruby
class Person < ApplicationRecord
  # 固定的消息
  validates :name, presence: { message: "必須提供" }

  # 帶有動態屬性值的消息。%{value} 將被替換為屬性的實際值。%{attribute} 和 %{model} 也可用。
  validates :age, numericality: { message: "%{value} 似乎不正確" }
end
```

`Proc` `:message` 值接受兩個參數：正在驗證的對象和帶有 `:model`、`:attribute` 和 `:value` 鍵值對的哈希。

```ruby
class Person < ApplicationRecord
  validates :username,
    uniqueness: {
      # object = 正在驗證的 person 對象
      # data = { model: "Person", attribute: "Username", value: <username> }
      message: ->(object, data) do
        "嘿 #{object.name}，#{data[:value]} 已經被使用了。"
      end
    }
end
```

### `:on`

`：on` 選項允許您指定驗證應該在何時發生。所有內建的驗證助手的默認行為是在保存時運行（在創建新記錄和更新記錄時都是如此）。如果您想要更改它，可以使用 `on: :create` 只在創建新記錄時運行驗證，或使用 `on: :update` 只在更新記錄時運行驗證。

```ruby
class Person < ApplicationRecord
  # 可以使用重複的電子郵件更新
  validates :email, uniqueness: true, on: :create

  # 可以使用非數字的年齡創建記錄
  validates :age, numericality: true, on: :update

  # 默認（在創建和更新時驗證）
  validates :name, presence: true
end
```

您還可以使用 `on:` 定義自定義上下文。必須通過將上下文的名稱傳遞給 `valid?`、`invalid?` 或 `save` 來明確觸發自定義上下文。

```ruby
class Person < ApplicationRecord
  validates :email, uniqueness: true, on: :account_setup
  validates :age, numericality: true, on: :account_setup
end
```

```irb
irb> person = Person.new(age: '三十三')
irb> person.valid?
=> true
irb> person.valid?(:account_setup)
=> false
irb> person.errors.messages
=> {:email=>["已經被使用了"], :age=>["不是數字"]}
```

`person.valid?(:account_setup)` 在不保存模型的情況下執行兩個驗證。`person.save(context: :account_setup)` 在保存之前在 `account_setup` 上下文中驗證 `person`。

也可以傳遞符號數組。

```ruby
class Book
  include ActiveModel::Validations

  validates :title, presence: true, on: [:update, :ensure_title]
end
```

```irb
irb> book = Book.new(title: nil)
irb> book.valid?
=> true
irb> book.valid?(:ensure_title)
=> false
irb> book.errors.messages
=> {:title=>["不能為空"]}
```

當由明確上下文觸發時，將運行該上下文的驗證，以及**沒有**上下文的驗證。

```ruby
class Person < ApplicationRecord
  validates :email, uniqueness: true, on: :account_setup
  validates :age, numericality: true, on: :account_setup
  validates :name, presence: true
end
```

```irb
irb> person = Person.new
irb> person.valid?(:account_setup)
=> false
irb> person.errors.messages
=> {:email=>["已經被使用了"], :age=>["不是數字"], :name=>["不能為空"]}
```

我們將在 [回調指南](active_record_callbacks.html) 中介紹更多 `on:` 的用例。

嚴格驗證
------------------

您還可以指定驗證為嚴格驗證，並在對象無效時引發 `ActiveModel::StrictValidationFailed`。

```ruby
class Person < ApplicationRecord
  validates :name, presence: { strict: true }
end
```

```irb
irb> Person.new.valid?
ActiveModel::StrictValidationFailed: 名稱不能為空
```

還可以將自定義異常傳遞給 `:strict` 選項。

```ruby
class Person < ApplicationRecord
  validates :token, presence: true, uniqueness: true, strict: TokenGenerationException
end
```

```irb
irb> Person.new.valid?
TokenGenerationException: Token 不能為空
```

條件驗證
----------------------

有時候只有在滿足特定條件時才對對象進行驗證才有意義。您可以使用 `:if` 和 `:unless` 選項來實現這一點，這些選項可以接受符號、`Proc` 或 `Array`。當您希望指定驗證**應該**發生時，可以使用 `:if` 選項。或者，如果您希望指定驗證**不應該**發生時，則可以使用 `:unless` 選項。
### 使用 `:if` 和 `:unless` 的符號

您可以將 `:if` 和 `:unless` 選項與對應於在驗證之前將被調用的方法名稱相關聯。這是最常用的選項。

```ruby
class Order < ApplicationRecord
  validates :card_number, presence: true, if: :paid_with_card?

  def paid_with_card?
    payment_type == "card"
  end
end
```

### 使用 `:if` 和 `:unless` 的 Proc

可以將 `:if` 和 `:unless` 與 `Proc` 對象相關聯，並將其調用。使用 `Proc` 對象可以讓您編寫內聯條件而不是單獨的方法。此選項最適合單行程式碼。

```ruby
class Account < ApplicationRecord
  validates :password, confirmation: true,
    unless: Proc.new { |a| a.password.blank? }
end
```

由於 `lambda` 是 `Proc` 的一種類型，因此也可以使用縮短的語法來編寫內聯條件。

```ruby
validates :password, confirmation: true, unless: -> { password.blank? }
```

### 分組條件驗證

有時候，將多個驗證使用同一個條件是很有用的。可以使用 [`with_options`][] 輕鬆實現。

```ruby
class User < ApplicationRecord
  with_options if: :is_admin? do |admin|
    admin.validates :password, length: { minimum: 10 }
    admin.validates :email, presence: true
  end
end
```

`with_options` 塊內的所有驗證將自動通過條件 `if: :is_admin?`。

### 組合驗證條件

另一方面，當多個條件定義驗證是否應該發生時，可以使用 `Array`。此外，您可以將 `:if` 和 `:unless` 同時應用於同一個驗證。

```ruby
class Computer < ApplicationRecord
  validates :mouse, presence: true,
                    if: [Proc.new { |c| c.market.retail? }, :desktop?],
                    unless: Proc.new { |c| c.trackpad.present? }
end
```

只有當所有 `:if` 條件都評估為 `true`，且所有 `:unless` 條件都評估為 `false` 時，驗證才會運行。

執行自定義驗證
-----------------------------

當內置的驗證幫助程序無法滿足您的需求時，可以根據需要編寫自己的驗證器或驗證方法。

### 自定義驗證器

自定義驗證器是繼承自 [`ActiveModel::Validator`][] 的類。這些類必須實現 `validate` 方法，該方法接受一個記錄作為參數，並對其執行驗證。使用 `validates_with` 方法調用自定義驗證器。

```ruby
class MyValidator < ActiveModel::Validator
  def validate(record)
    unless record.name.start_with? 'X'
      record.errors.add :name, "請提供以 X 開頭的名稱！"
    end
  end
end

class Person < ApplicationRecord
  validates_with MyValidator
end
```

使用方便的 [`ActiveModel::EachValidator`][] 最簡單地為驗證單個屬性添加自定義驗證器。在這種情況下，自定義驗證器類必須實現一個 `validate_each` 方法，該方法接受三個參數：記錄、要驗證的屬性和傳遞的實例中屬性的值。

```ruby
class EmailValidator < ActiveModel::EachValidator
  def validate_each(record, attribute, value)
    unless URI::MailTo::EMAIL_REGEXP.match?(value)
      record.errors.add attribute, (options[:message] || "不是有效的電子郵件")
    end
  end
end

class Person < ApplicationRecord
  validates :email, presence: true, email: true
end
```

如示例所示，您還可以將標準驗證與自己的自定義驗證器結合使用。

### 自定義方法

您還可以創建驗證模型狀態並在無效時將錯誤添加到 `errors` 集合中的方法。然後，您可以使用 [`validate`][] 類方法註冊這些方法，並傳遞驗證方法名的符號。

每個類方法可以傳遞多個符號，相應的驗證將按照註冊的順序運行。

`valid?` 方法將驗證 `errors` 集合是否為空，因此當您希望驗證失敗時，自定義驗證方法應將錯誤添加到其中：

```ruby
class Invoice < ApplicationRecord
  validate :expiration_date_cannot_be_in_the_past,
    :discount_cannot_be_greater_than_total_value

  def expiration_date_cannot_be_in_the_past
    if expiration_date.present? && expiration_date < Date.today
      errors.add(:expiration_date, "不能在過去")
    end
  end

  def discount_cannot_be_greater_than_total_value
    if discount > total_value
      errors.add(:discount, "不能大於總值")
    end
  end
end
```

默認情況下，這些驗證將在每次調用 `valid?` 或保存對象時運行。但是，也可以通過給 `validate` 方法提供 `:on` 選項來控制何時運行這些自定義驗證，選項可以是 `:create` 或 `:update`。

```ruby
class Invoice < ApplicationRecord
  validate :active_customer, on: :create

  def active_customer
    errors.add(:customer_id, "不是活動的") unless customer.active?
  end
end
```
請參閱上面的章節以獲取有關 [`:on`](#on) 的更多詳細信息。

### 列出驗證器

如果您想找出給定對象的所有驗證器，那麼您可以使用 `validators`。

例如，如果我們有以下使用自定義驗證器和內置驗證器的模型：

```ruby
class Person < ApplicationRecord
  validates :name, presence: true, on: :create
  validates :email, format: URI::MailTo::EMAIL_REGEXP
  validates_with MyOtherValidator, strict: true
end
```

我們現在可以在 "Person" 模型上使用 `validators` 列出所有驗證器，或者使用 `validators_on` 檢查特定字段。

```irb
irb> Person.validators
#=> [#<ActiveRecord::Validations::PresenceValidator:0x10b2f2158
      @attributes=[:name], @options={:on=>:create}>,
     #<MyOtherValidatorValidator:0x10b2f17d0
      @attributes=[:name], @options={:strict=>true}>,
     #<ActiveModel::Validations::FormatValidator:0x10b2f0f10
      @attributes=[:email],
      @options={:with=>URI::MailTo::EMAIL_REGEXP}>]
     #<MyOtherValidator:0x10b2f0948 @options={:strict=>true}>]

irb> Person.validators_on(:name)
#=> [#<ActiveModel::Validations::PresenceValidator:0x10b2f2158
      @attributes=[:name], @options={on: :create}>]
```


處理驗證錯誤
------------------------------

[`valid?`][] 和 [`invalid?`][] 方法僅提供關於有效性的摘要狀態。但是，您可以使用 [`errors`][] 集合中的各種方法深入研究每個單獨的錯誤。

以下是最常用的方法列表。有關所有可用方法的列表，請參閱 [`ActiveModel::Errors`][] 文檔。


### `errors`

通過此方法，您可以深入研究每個錯誤的各種詳細信息。

它返回一個包含所有錯誤的 `ActiveModel::Errors` 類的實例，每個錯誤由一個 [`ActiveModel::Error`][] 對象表示。

```ruby
class Person < ApplicationRecord
  validates :name, presence: true, length: { minimum: 3 }
end
```

```irb
irb> person = Person.new
irb> person.valid?
=> false
irb> person.errors.full_messages
=> ["名稱不能為空", "名稱太短（最少為 3 個字符）"]

irb> person = Person.new(name: "John Doe")
irb> person.valid?
=> true
irb> person.errors.full_messages
=> []

irb> person = Person.new
irb> person.valid?
=> false
irb> person.errors.first.details
=> {:error=>:too_short, :count=>3}
```


### `errors[]`

當您想要檢查特定屬性的錯誤消息時，可以使用 [`errors[]`][Errors#squarebrackets]。它返回一個字符串數組，其中包含給定屬性的所有錯誤消息，每個字符串包含一個錯誤消息。如果沒有與該屬性相關的錯誤，則返回一個空數組。

```ruby
class Person < ApplicationRecord
  validates :name, presence: true, length: { minimum: 3 }
end
```

```irb
irb> person = Person.new(name: "John Doe")
irb> person.valid?
=> true
irb> person.errors[:name]
=> []

irb> person = Person.new(name: "JD")
irb> person.valid?
=> false
irb> person.errors[:name]
=> ["太短（最少為 3 個字符）"]

irb> person = Person.new
irb> person.valid?
=> false
irb> person.errors[:name]
=> ["不能為空", "太短（最少為 3 個字符）"]
```

### `errors.where` 和錯誤對象

有時我們可能需要更多有關每個錯誤的信息，而不僅僅是其消息。每個錯誤都封裝為一個 `ActiveModel::Error` 對象，而 [`where`][] 方法是訪問的最常用方式。

`where` 方法返回一個按各種條件過濾的錯誤對象數組。

```ruby
class Person < ApplicationRecord
  validates :name, presence: true, length: { minimum: 3 }
end
```

我們可以通過將其作為第一個參數傳遞給 `errors.where(:attr)`，來僅過濾 `attribute`。第二個參數用於通過調用 `errors.where(:attr, :type)` 來過濾我們想要的 `type` 的錯誤。

```irb
irb> person = Person.new
irb> person.valid?
=> false

irb> person.errors.where(:name)
=> [ ... ] # :name 屬性的所有錯誤

irb> person.errors.where(:name, :too_short)
=> [ ... ] # :name 屬性的 :too_short 錯誤
```

最後，我們可以根據可能存在於給定類型錯誤對象上的任何 `options` 進行過濾。

```irb
irb> person = Person.new
irb> person.valid?
=> false

irb> person.errors.where(:name, :too_short, minimum: 3)
=> [ ... ] # 所有名稱錯誤都太短，並且最小值為 2
```

您可以從這些錯誤對象中讀取各種信息：

```irb
irb> error = person.errors.where(:name).last

irb> error.attribute
=> :name
irb> error.type
=> :too_short
irb> error.options[:count]
=> 3
```

您還可以生成錯誤消息：

```irb
irb> error.message
=> "太短（最少為 3 個字符）"
irb> error.full_message
=> "名稱太短（最少為 3 個字符）"
```

[`full_message`][] 方法生成一個更加用戶友好的消息，其中包含大寫的屬性名稱作為前綴。（要自定義 `full_message` 使用的格式，請參閱 [I18n 指南](i18n.html#active-model-methods)。）


### `errors.add`

[`add`][] 方法通過接受 `attribute`、錯誤 `type` 和其他選項哈希來創建錯誤對象。當編寫自己的驗證器時，這非常有用，因為它允許您定義非常具體的錯誤情況。

```ruby
class Person < ApplicationRecord
  validate do |person|
    errors.add :name, :too_plain, message: "不夠酷"
  end
end
```
```irb
irb> person = Person.create
irb> person.errors.where(:name).first.type
=> :too_plain
irb> person.errors.where(:name).first.full_message
=> "名稱不夠酷"
```


### `errors[:base]`

您可以添加與對象整體狀態相關的錯誤，而不是與特定屬性相關的錯誤。要做到這一點，您必須在添加新錯誤時使用 `:base` 作為屬性。

```ruby
class Person < ApplicationRecord
  validate do |person|
    errors.add :base, :invalid, message: "這個人無效，因為..."
  end
end
```

```irb
irb> person = Person.create
irb> person.errors.where(:base).first.full_message
=> "這個人無效，因為..."
```

### `errors.size`

`size` 方法返回對象的錯誤總數。

```ruby
class Person < ApplicationRecord
  validates :name, presence: true, length: { minimum: 3 }
end
```

```irb
irb> person = Person.new
irb> person.valid?
=> false
irb> person.errors.size
=> 2

irb> person = Person.new(name: "Andrea", email: "andrea@example.com")
irb> person.valid?
=> true
irb> person.errors.size
=> 0
```

### `errors.clear`

`clear` 方法用於當您有意要清除 `errors` 集合時使用。當然，在無效對象上調用 `errors.clear` 不會使其有效：`errors` 集合現在將為空，但下一次調用 `valid?` 或任何嘗試將此對象保存到數據庫的方法時，驗證將再次運行。如果任何驗證失敗，`errors` 集合將再次填充。

```ruby
class Person < ApplicationRecord
  validates :name, presence: true, length: { minimum: 3 }
end
```

```irb
irb> person = Person.new
irb> person.valid?
=> false
irb> person.errors.empty?
=> false

irb> person.errors.clear
irb> person.errors.empty?
=> true

irb> person.save
=> false

irb> person.errors.empty?
=> false
```

在視圖中顯示驗證錯誤
-------------------------------------

一旦您創建了一個模型並添加了驗證，如果通過網絡表單創建該模型，您可能希望在驗證失敗時顯示錯誤消息。

由於每個應用程序處理這種類型的事情的方式不同，Rails 不包含任何視圖輔助程序來直接幫助您生成這些消息。但是，由於 Rails 提供了豐富的方法與驗證進行交互，您可以自己構建。此外，當生成脚手架時，Rails 會將一些 ERB 放入生成的 `_form.html.erb` 中，以顯示該模型的完整錯誤列表。

假設我們有一個已保存在名為 `@article` 的實例變量中的模型，它看起來像這樣：

```html+erb
<% if @article.errors.any? %>
  <div id="error_explanation">
    <h2><%= pluralize(@article.errors.count, "個錯誤") %> 阻止保存此文章：</h2>

    <ul>
      <% @article.errors.each do |error| %>
        <li><%= error.full_message %></li>
      <% end %>
    </ul>
  </div>
<% end %>
```

此外，如果您使用 Rails 表單輔助程序生成表單，當字段上發生驗證錯誤時，它將在輸入周圍生成額外的 `<div>`。

```html
<div class="field_with_errors">
  <input id="article_title" name="article[title]" size="30" type="text" value="">
</div>
```

然後，您可以按照自己的喜好設置此 div 的樣式。例如，Rails 生成的默認脚手架添加了以下 CSS 規則：

```css
.field_with_errors {
  padding: 2px;
  background-color: red;
  display: table;
}
```

這意味著任何帶有錯誤的字段最終都會有一個 2 像素的紅色邊框。
[`errors`]: https://api.rubyonrails.org/classes/ActiveModel/Validations.html#method-i-errors
[`invalid?`]: https://api.rubyonrails.org/classes/ActiveModel/Validations.html#method-i-invalid-3F
[`valid?`]: https://api.rubyonrails.org/classes/ActiveRecord/Validations.html#method-i-valid-3F
[Errors#squarebrackets]: https://api.rubyonrails.org/classes/ActiveModel/Errors.html#method-i-5B-5D
[`ActiveModel::Validations::HelperMethods`]: https://api.rubyonrails.org/classes/ActiveModel/Validations/HelperMethods.html
[`Object#blank?`]: https://api.rubyonrails.org/classes/Object.html#method-i-blank-3F
[`Object#present?`]: https://api.rubyonrails.org/classes/Object.html#method-i-present-3F
[`validates_uniqueness_of`]: https://api.rubyonrails.org/classes/ActiveRecord/Validations/ClassMethods.html#method-i-validates_uniqueness_of
[`add_index`]: https://api.rubyonrails.org/classes/ActiveRecord/ConnectionAdapters/SchemaStatements.html#method-i-add_index
[`validates_associated`]: https://api.rubyonrails.org/classes/ActiveRecord/Validations/ClassMethods.html#method-i-validates_associated
[`validates_each`]: https://api.rubyonrails.org/classes/ActiveModel/Validations/ClassMethods.html#method-i-validates_each
[`validates_with`]: https://api.rubyonrails.org/classes/ActiveModel/Validations/ClassMethods.html#method-i-validates_with
[`ActiveModel::Validations`]: https://api.rubyonrails.org/classes/ActiveModel/Validations.html
[`with_options`]: https://api.rubyonrails.org/classes/Object.html#method-i-with_options
[`ActiveModel::EachValidator`]: https://api.rubyonrails.org/classes/ActiveModel/EachValidator.html
[`ActiveModel::Validator`]: https://api.rubyonrails.org/classes/ActiveModel/Validator.html
[`validate`]: https://api.rubyonrails.org/classes/ActiveModel/Validations/ClassMethods.html#method-i-validate
[`ActiveModel::Errors`]: https://api.rubyonrails.org/classes/ActiveModel/Errors.html
[`ActiveModel::Error`]: https://api.rubyonrails.org/classes/ActiveModel/Error.html
[`full_message`]: https://api.rubyonrails.org/classes/ActiveModel/Errors.html#method-i-full_message
[`where`]: https://api.rubyonrails.org/classes/ActiveModel/Errors.html#method-i-where
[`add`]: https://api.rubyonrails.org/classes/ActiveModel/Errors.html#method-i-add
