**DO NOT READ THIS FILE ON GITHUB, GUIDES ARE PUBLISHED ON https://guides.rubyonrails.org.**, original file md5: fdd2e5c41171c61b555549ced4d68a82
Active Support 核心擴展
====================

Active Support 是 Ruby on Rails 的組件，負責提供 Ruby 語言的擴展和工具。

它在語言層面上提供了更豐富的功能，既適用於開發 Rails 應用程序，也適用於開發 Ruby on Rails 本身。

閱讀本指南後，您將了解：

* 什麼是核心擴展。
* 如何加載所有擴展。
* 如何挑選您想要的擴展。
* Active Support 提供了哪些擴展。

--------------------------------------------------------------------------------

如何加載核心擴展
---------------------------

### 獨立的 Active Support

為了使默認的佔用空間最小，Active Support 默認只加載最少的依賴項。它被拆分成小塊，以便只加載所需的擴展。它還提供了一些方便的入口點，以一次性加載相關的擴展，甚至是全部。

因此，只需簡單的 require：

```ruby
require "active_support"
```

只會加載 Active Support 框架所需的擴展。

#### 挑選定義

以下示例演示了如何加載 [`Hash#with_indifferent_access`][Hash#with_indifferent_access]。該擴展使得可以將 `Hash` 轉換為 [`ActiveSupport::HashWithIndifferentAccess`][ActiveSupport::HashWithIndifferentAccess]，從而可以使用字符串或符號作為鍵。

```ruby
{ a: 1 }.with_indifferent_access["a"] # => 1
```

對於每個定義為核心擴展的方法，本指南都有一個說明該方法定義在哪裡的註釋。對於 `with_indifferent_access`，註釋如下：

注意：定義在 `active_support/core_ext/hash/indifferent_access.rb` 中。

這意味著您可以這樣 require：

```ruby
require "active_support"
require "active_support/core_ext/hash/indifferent_access"
```

Active Support 經過精心修訂，因此挑選一個文件只會加載嚴格需要的依賴項（如果有的話）。

#### 加載分組的核心擴展

下一級是只需加載所有 `Hash` 的擴展。作為一個經驗法則，對於 `SomeClass` 的擴展可以通過加載 `active_support/core_ext/some_class` 一次性加載。

因此，要加載所有 `Hash` 的擴展（包括 `with_indifferent_access`）：

```ruby
require "active_support"
require "active_support/core_ext/hash"
```

#### 加載所有核心擴展

您可能只想加載所有核心擴展，有一個文件可以實現：

```ruby
require "active_support"
require "active_support/core_ext"
```

#### 加載所有 Active Support

最後，如果您想要加載所有 Active Support，只需執行以下操作：

```ruby
require "active_support/all"
```

實際上，這甚至不會將整個 Active Support 預先加載到內存中，一些內容是通過 `autoload` 配置的，只有在使用時才會加載。

### 在 Ruby on Rails 應用程序中使用 Active Support

Ruby on Rails 應用程序會加載所有 Active Support，除非 [`config.active_support.bare`][] 為 true。在這種情況下，應用程序只會加載框架本身為自己需要的內容進行挑選，並且仍然可以按照前一節中的說明進行任意細粒度的挑選。


對所有對象的擴展
-------------------------

### `blank?` 和 `present?`

在 Rails 應用程序中，以下值被視為空白：

* `nil` 和 `false`，

* 只包含空白字符的字符串（請參閱下面的註釋），

* 空數組和哈希，以及

* 任何其他對象，如果該對象響應 `empty?` 並且為空。

INFO: 字符串的判斷使用了支持 Unicode 的字符類 `[:space:]`，因此例如 U+2029（段落分隔符）被視為空白字符。
警告：請注意，文中未提及數字。特別是，0 和 0.0 **不是**空白。

例如，`ActionController::HttpAuthentication::Token::ControllerMethods` 中的這個方法使用 [`blank?`][Object#blank?] 檢查令牌是否存在：

```ruby
def authenticate(controller, &login_procedure)
  token, options = token_and_options(controller.request)
  unless token.blank?
    login_procedure.call(token, options)
  end
end
```

[`present?`][Object#present?] 方法等同於 `!blank?`。這個例子來自 `ActionDispatch::Http::Cache::Response`：

```ruby
def set_conditional_cache_control!
  return if self["Cache-Control"].present?
  # ...
end
```

注意：定義在 `active_support/core_ext/object/blank.rb` 中。


### `presence`

[`presence`][Object#presence] 方法如果 `present?` 則返回接收者本身，否則返回 `nil`。這在以下情況下很有用：

```ruby
host = config[:host].presence || 'localhost'
```

注意：定義在 `active_support/core_ext/object/blank.rb` 中。


### `duplicable?`

從 Ruby 2.5 開始，大多數對象都可以通過 `dup` 或 `clone` 進行複製：

```ruby
"foo".dup           # => "foo"
"".dup              # => ""
Rational(1).dup     # => (1/1)
Complex(0).dup      # => (0+0i)
1.method(:+).dup    # => TypeError (allocator undefined for Method)
```

Active Support 提供 [`duplicable?`][Object#duplicable?] 來查詢對象是否可複製：

```ruby
"foo".duplicable?           # => true
"".duplicable?              # => true
Rational(1).duplicable?     # => true
Complex(1).duplicable?      # => true
1.method(:+).duplicable?    # => false
```

警告：任何類都可以通過刪除 `dup` 和 `clone` 或從中引發異常來禁止複製。因此，只有 `rescue` 可以告訴您給定的任意對象是否可複製。`duplicable?` 依賴於上面的硬編碼列表，但它比 `rescue` 快得多。只有在您知道硬編碼列表在您的用例中足夠時才使用它。

注意：定義在 `active_support/core_ext/object/duplicable.rb` 中。


### `deep_dup`

[`deep_dup`][Object#deep_dup] 方法返回給定對象的深度副本。通常，當您對包含其他對象的對象進行 `dup` 時，Ruby 不會對它們進行 `dup`，因此它創建了對象的淺層副本。例如，如果您有一個包含字符串的數組，它會像這樣：

```ruby
array     = ['string']
duplicate = array.dup

duplicate.push 'another-string'

# 對象已複製，因此元素僅添加到副本中
array     # => ['string']
duplicate # => ['string', 'another-string']

duplicate.first.gsub!('string', 'foo')

# 第一個元素未複製，它將在兩個數組中更改
array     # => ['foo']
duplicate # => ['foo', 'another-string']
```

如您所見，在複製 `Array` 實例之後，我們得到了另一個對象，因此我們可以修改它，而原始對象將保持不變。但是，對於數組的元素來說，情況並非如此。由於 `dup` 不進行深度複製，數組內部的字符串仍然是同一個對象。

如果您需要對象的深度副本，應該使用 `deep_dup`。這是一個例子：

```ruby
array     = ['string']
duplicate = array.deep_dup

duplicate.first.gsub!('string', 'foo')

array     # => ['string']
duplicate # => ['foo']
```

如果對象不可複製，`deep_dup` 將返回它本身：

```ruby
number = 1
duplicate = number.deep_dup
number.object_id == duplicate.object_id   # => true
```

注意：定義在 `active_support/core_ext/object/deep_dup.rb` 中。


### `try`

當您只想在對象不為 `nil` 時調用一個方法時，最簡單的方法是使用條件語句，這會增加不必要的雜亂。另一種方法是使用 [`try`][Object#try]。`try` 類似於 `Object#public_send`，但如果發送給 `nil`，它會返回 `nil`。
以下是一個例子：

```ruby
# 沒有使用 try
unless @number.nil?
  @number.next
end

# 使用 try
@number.try(:next)
```

另一個例子是來自 `ActiveRecord::ConnectionAdapters::AbstractAdapter` 的程式碼，其中 `@logger` 可能為 `nil`。你可以看到程式碼使用了 `try` 並避免了不必要的檢查。

```ruby
def log_info(sql, name, ms)
  if @logger.try(:debug?)
    name = '%s (%.1fms)' % [name || 'SQL', ms]
    @logger.debug(format_log_entry(name, sql.squeeze(' ')))
  end
end
```

`try` 也可以在沒有參數但有區塊的情況下呼叫，只有在物件不為 nil 時才會執行該區塊：

```ruby
@person.try { |p| "#{p.first_name} #{p.last_name}" }
```

請注意，`try` 會吞掉不存在的方法錯誤，並返回 nil。如果你想要防止拼寫錯誤，可以使用 [`try!`][Object#try!]：

```ruby
@number.try(:nest)  # => nil
@number.try!(:nest) # NoMethodError: undefined method `nest' for 1:Integer
```

注意：`try` 定義在 `active_support/core_ext/object/try.rb` 中。


### `class_eval(*args, &block)`

你可以使用 [`class_eval`][Kernel#class_eval] 在任何物件的單例類別中評估程式碼：

```ruby
class Proc
  def bind(object)
    block, time = self, Time.current
    object.class_eval do
      method_name = "__bind_#{time.to_i}_#{time.usec}"
      define_method(method_name, &block)
      method = instance_method(method_name)
      remove_method(method_name)
      method
    end.bind(object)
  end
end
```

注意：`class_eval` 定義在 `active_support/core_ext/kernel/singleton_class.rb` 中。


### `acts_like?(duck)`

[`acts_like?`][Object#acts_like?] 方法提供了一種檢查某個類別是否像另一個類別一樣的方式，基於一個簡單的約定：一個提供與 `String` 相同介面的類別定義了

```ruby
def acts_like_string?
end
```

這只是一個標記，它的內容或返回值都不重要。然後，客戶端程式碼可以這樣查詢是否符合鴨子類型：

```ruby
some_klass.acts_like?(:string)
```

Rails 中有一些類別像 `Date` 或 `Time` 並遵循這個約定。

注意：`acts_like?` 定義在 `active_support/core_ext/object/acts_like.rb` 中。


### `to_param`

Rails 中的所有物件都會回應 [`to_param`][Object#to_param] 方法，該方法用於返回一個代表它們作為查詢字串或 URL 片段的值。

預設情況下，`to_param` 只會呼叫 `to_s`：

```ruby
7.to_param # => "7"
```

`to_param` 的返回值**不應該**被轉義：

```ruby
"Tom & Jerry".to_param # => "Tom & Jerry"
```

Rails 中的幾個類別會覆寫這個方法。

例如，`nil`、`true` 和 `false` 會返回它們自己。[`Array#to_param`][Array#to_param] 會對元素調用 `to_param`，並使用 "/" 將結果連接起來：

```ruby
[0, true, String].to_param # => "0/true/String"
```

值得注意的是，Rails 的路由系統會對模型調用 `to_param` 以獲取 `:id` 佔位符的值。`ActiveRecord::Base#to_param` 返回模型的 `id`，但你可以在你的模型中重新定義該方法。例如，假設有以下定義：

```ruby
class User
  def to_param
    "#{id}-#{name.parameterize}"
  end
end
```

我們可以得到：

```ruby
user_path(@user) # => "/users/357-john-smith"
```

警告：控制器需要注意 `to_param` 的重新定義，因為當像這樣的請求進來時，"357-john-smith" 是 `params[:id]` 的值。

注意：`to_param` 定義在 `active_support/core_ext/object/to_param.rb` 中。


### `to_query`

[`to_query`][Object#to_query] 方法構造一個查詢字串，將給定的 `key` 與 `to_param` 的返回值關聯起來。例如，有以下 `to_param` 定義：

```ruby
class User
  def to_param
    "#{id}-#{name.parameterize}"
  end
end
```

我們可以得到：

```ruby
current_user.to_query('user') # => "user=357-john-smith"
```

該方法會對需要的內容進行轉義，包括鍵和值：

```ruby
account.to_query('company[name]')
# => "company%5Bname%5D=Johnson+%26+Johnson"
```

因此，它的輸出已經可以在查詢字串中使用。
陣列返回將每個元素應用`to_query`的結果，並使用`key[]`作為鍵，將結果連接起來，中間用"&"分隔：

```ruby
[3.4, -45.6].to_query('sample')
# => "sample%5B%5D=3.4&sample%5B%5D=-45.6"
```

哈希也可以使用`to_query`，但使用不同的參數。如果沒有傳遞參數，則會生成一系列按鍵/值分配的排序結果，並在其值上調用`to_query(key)`。然後將結果用"&"連接起來：

```ruby
{ c: 3, b: 2, a: 1 }.to_query # => "a=1&b=2&c=3"
```

方法[`Hash#to_query`][Hash#to_query]接受可選的命名空間作為鍵：

```ruby
{ id: 89, name: "John Smith" }.to_query('user')
# => "user%5Bid%5D=89&user%5Bname%5D=John+Smith"
```

注意：定義在`active_support/core_ext/object/to_query.rb`中。


### `with_options`

方法[`with_options`][Object#with_options]提供了一種在一系列方法調用中提取公共選項的方式。

給定一個默認的選項哈希，`with_options`會將一個代理對象傳遞給塊。在塊內，對代理調用的方法將與其選項合併後轉發給接收者。例如，你可以通過以下方式消除重複：

```ruby
class Account < ApplicationRecord
  has_many :customers, dependent: :destroy
  has_many :products,  dependent: :destroy
  has_many :invoices,  dependent: :destroy
  has_many :expenses,  dependent: :destroy
end
```

改為：

```ruby
class Account < ApplicationRecord
  with_options dependent: :destroy do |assoc|
    assoc.has_many :customers
    assoc.has_many :products
    assoc.has_many :invoices
    assoc.has_many :expenses
  end
end
```

這種用法也可以傳達給讀者的“分組”意圖。例如，假設你想要發送一封新聞通訊，其語言取決於用戶。你可以在郵件程序的某個地方像這樣分組依賴於語言的部分：

```ruby
I18n.with_options locale: user.locale, scope: "newsletter" do |i18n|
  subject i18n.t :subject
  body    i18n.t :body, user_name: user.name
end
```

提示：由於`with_options`將調用轉發給其接收者，因此可以進行嵌套。每個嵌套級別都將合併繼承的默認值以及自己的默認值。

注意：定義在`active_support/core_ext/object/with_options.rb`中。


### JSON支持

Active Support提供了比Ruby對象通常提供的`json` gem更好的`to_json`實現。這是因為一些類，如`Hash`和`Process::Status`，需要特殊處理才能提供正確的JSON表示。

注意：定義在`active_support/core_ext/object/json.rb`中。

### 實例變量

Active Support提供了幾個方法來方便訪問實例變量。

#### `instance_values`

方法[`instance_values`][Object#instance_values]返回一個將實例變量名（不包含“@”）映射到其對應值的哈希。鍵是字符串：

```ruby
class C
  def initialize(x, y)
    @x, @y = x, y
  end
end

C.new(0, 1).instance_values # => {"x" => 0, "y" => 1}
```

注意：定義在`active_support/core_ext/object/instance_variables.rb`中。


#### `instance_variable_names`

方法[`instance_variable_names`][Object#instance_variable_names]返回一個數組。每個名稱都包含“@”符號。

```ruby
class C
  def initialize(x, y)
    @x, @y = x, y
  end
end

C.new(0, 1).instance_variable_names # => ["@x", "@y"]
```

注意：定義在`active_support/core_ext/object/instance_variables.rb`中。


### 禁止警告和異常

方法[`silence_warnings`][Kernel#silence_warnings]和[`enable_warnings`][Kernel#enable_warnings]會在其塊的執行期間相應地更改`$VERBOSE`的值，並在之後重置它：

```ruby
silence_warnings { Object.const_set "RAILS_DEFAULT_LOGGER", logger }
```

使用[`suppress`][Kernel#suppress]也可以禁止異常。此方法接收任意數量的異常類。如果在塊的執行過程中引發了異常並且`kind_of?`任何參數的類型，則`suppress`會捕獲它並靜默返回。否則，異常不會被捕獲：
```ruby
# 如果使用者被鎖定，增量將會遺失，不會有太大問題。
suppress(ActiveRecord::StaleObjectError) do
  current_user.increment! :visits
end
```

注意：定義在 `active_support/core_ext/kernel/reporting.rb` 中。


### `in?`

謂詞 [`in?`][Object#in?] 測試一個物件是否包含在另一個物件中。如果傳遞的參數不回應 `include?`，則會引發 `ArgumentError` 例外。

`in?` 的範例：

```ruby
1.in?([1, 2])        # => true
"lo".in?("hello")   # => true
25.in?(30..50)      # => false
1.in?(1)            # => ArgumentError
```

注意：定義在 `active_support/core_ext/object/inclusion.rb` 中。


`Module` 的擴充
----------------------

### 屬性

#### `alias_attribute`

模型屬性具有讀取器、寫入器和謂詞。你可以使用 [`alias_attribute`][Module#alias_attribute] 為模型屬性建立對應的三個方法的別名。與其他別名方法一樣，新名稱是第一個參數，舊名稱是第二個參數（一個助記法是它們的順序與賦值相同）：

```ruby
class User < ApplicationRecord
  # 你可以將 email 欄位稱為 "login"。
  # 對於身份驗證代碼來說，這可能有意義。
  alias_attribute :login, :email
end
```

注意：定義在 `active_support/core_ext/module/aliasing.rb` 中。


#### 內部屬性

當你在一個預計被子類化的類中定義屬性時，名稱衝突是一個風險。這對於庫來說非常重要。

Active Support 定義了宏 [`attr_internal_reader`][Module#attr_internal_reader]、[`attr_internal_writer`][Module#attr_internal_writer] 和 [`attr_internal_accessor`][Module#attr_internal_accessor]。它們的行為與 Ruby 內建的 `attr_*` 相同，只是它們以一種使衝突更少可能的方式命名底層實例變數。

宏 [`attr_internal`][Module#attr_internal] 是 `attr_internal_accessor` 的同義詞：

```ruby
# 库
class ThirdPartyLibrary::Crawler
  attr_internal :log_level
end

# 客戶端代碼
class MyCrawler < ThirdPartyLibrary::Crawler
  attr_accessor :log_level
end
```

在上面的例子中，`:log_level` 可能不屬於庫的公共接口，只在開發中使用。客戶端代碼不知道潛在的衝突，子類化並定義了自己的 `:log_level`。由於 `attr_internal`，沒有衝突。

默認情況下，內部實例變數以下劃線開頭命名，例如上面的例子中的 `@_log_level`。這可以通過 `Module.attr_internal_naming_format` 進行配置，你可以傳遞任何具有前導 `@` 和某處包含名稱的 `%s` 的 `sprintf`-like 格式字符串，名稱將放在那裡。默認值為 `"@_%s"`。

Rails 在一些地方使用內部屬性，例如視圖：

```ruby
module ActionView
  class Base
    attr_internal :captures
    attr_internal :request, :layout
    attr_internal :controller, :template
  end
end
```

注意：定義在 `active_support/core_ext/module/attr_internal.rb` 中。


#### 模組屬性

宏 [`mattr_reader`][Module#mattr_reader]、[`mattr_writer`][Module#mattr_writer] 和 [`mattr_accessor`][Module#mattr_accessor] 與為類定義的 `cattr_*` 宏相同。實際上，`cattr_*` 宏只是 `mattr_*` 宏的別名。請參閱 [類屬性](#class-attributes)。

例如，Active Storage 的日誌記錄器 API 是使用 `mattr_accessor` 生成的：

```ruby
module ActiveStorage
  mattr_accessor :logger
end
```

注意：定義在 `active_support/core_ext/module/attribute_accessors.rb` 中。


### 父模組

#### `module_parent`

嵌套命名模組上的 [`module_parent`][Module#module_parent] 方法返回包含其對應常量的模組：

```ruby
module X
  module Y
    module Z
    end
  end
end
M = X::Y::Z

X::Y::Z.module_parent # => X::Y
M.module_parent       # => X::Y
```

如果模組是匿名的或屬於頂層，`module_parent` 返回 `Object`。
警告：請注意，在這種情況下，`module_parent_name` 返回 `nil`。

注意：定義於 `active_support/core_ext/module/introspection.rb`。


#### `module_parent_name`

在嵌套命名模組上，[`module_parent_name`][Module#module_parent_name] 方法返回包含對應常數的模組的完全限定名稱：

```ruby
module X
  module Y
    module Z
    end
  end
end
M = X::Y::Z

X::Y::Z.module_parent_name # => "X::Y"
M.module_parent_name       # => "X::Y"
```

對於頂層或匿名模組，`module_parent_name` 返回 `nil`。

警告：請注意，在這種情況下，`module_parent` 返回 `Object`。

注意：定義於 `active_support/core_ext/module/introspection.rb`。


#### `module_parents`

[`module_parents`][Module#module_parents] 方法在接收者上調用 `module_parent`，直到達到 `Object`。鏈將以陣列形式從底部到頂部返回：

```ruby
module X
  module Y
    module Z
    end
  end
end
M = X::Y::Z

X::Y::Z.module_parents # => [X::Y, X, Object]
M.module_parents       # => [X::Y, X, Object]
```

注意：定義於 `active_support/core_ext/module/introspection.rb`。


### 匿名模組

模組可能有或沒有名稱：

```ruby
module M
end
M.name # => "M"

N = Module.new
N.name # => "N"

Module.new.name # => nil
```

您可以使用預測方法 [`anonymous?`][Module#anonymous?] 檢查模組是否有名稱：

```ruby
module M
end
M.anonymous? # => false

Module.new.anonymous? # => true
```

請注意，無法訪問並不意味著是匿名的：

```ruby
module M
end

m = Object.send(:remove_const, :M)

m.anonymous? # => false
```

儘管如此，根據定義，匿名模組是無法訪問的。

注意：定義於 `active_support/core_ext/module/anonymous.rb`。


### 方法委派

#### `delegate`

宏 [`delegate`][Module#delegate] 提供了一種簡單的方法來轉發方法。

假設某個應用程序中的用戶在 `User` 模型中具有登錄信息，但在單獨的 `Profile` 模型中具有名稱和其他數據：

```ruby
class User < ApplicationRecord
  has_one :profile
end
```

使用該配置，您可以通過用戶的配置文件獲取用戶的名稱，`user.profile.name`，但仍然可以直接訪問該屬性可能很方便：

```ruby
class User < ApplicationRecord
  has_one :profile

  def name
    profile.name
  end
end
```

這就是 `delegate` 為您做的事情：

```ruby
class User < ApplicationRecord
  has_one :profile

  delegate :name, to: :profile
end
```

這樣更簡潔，意圖更明顯。

目標中的方法必須是公開的。

`delegate` 宏接受多個方法：

```ruby
delegate :name, :age, :address, :twitter, to: :profile
```

當插入到字符串中時，`:to` 選項應該變成一個求值為方法委派對象的表達式。通常是一個字符串或符號。這樣的表達式在接收者的上下文中求值：

```ruby
# 委派給 Rails 常數
delegate :logger, to: :Rails

# 委派給接收者的類
delegate :table_name, to: :class
```

警告：如果 `:prefix` 選項為 `true`，則這就不那麼通用，請參見下文。

默認情況下，如果委派引發 `NoMethodError`，並且目標為 `nil`，則異常將被傳播。您可以使用 `:allow_nil` 選項要求返回 `nil`：

```ruby
delegate :name, to: :profile, allow_nil: true
```

使用 `:allow_nil`，如果用戶沒有配置文件，則調用 `user.name` 將返回 `nil`。

選項 `:prefix` 將前綴添加到生成方法的名稱。這可能很方便，例如獲得更好的名稱：
```ruby
delegate :street, to: :address, prefix: true
```

前面的例子生成的是`address_street`而不是`street`。

警告：由於在這種情況下，生成的方法名由目標對象和目標方法名組成，所以`:to`選項必須是一個方法名。

也可以配置自定義的前綴：

```ruby
delegate :size, to: :attachment, prefix: :avatar
```

在前面的例子中，宏生成的是`avatar_size`而不是`size`。

選項`:private`可以改變方法的作用域：

```ruby
delegate :date_of_birth, to: :profile, private: true
```

委託的方法默認是公開的。傳遞`private: true`以更改這一點。

注意：定義在`active_support/core_ext/module/delegation.rb`中


#### `delegate_missing_to`

假設您希望將`User`對象中缺少的所有內容委託給`Profile`對象。[`delegate_missing_to`][Module#delegate_missing_to]宏讓您可以輕鬆實現這一點：

```ruby
class User < ApplicationRecord
  has_one :profile

  delegate_missing_to :profile
end
```

目標可以是對象內的任何可調用項，例如實例變量、方法、常量等。只有目標的公共方法被委託。

注意：定義在`active_support/core_ext/module/delegation.rb`中。


### 重新定義方法

有些情況下，您需要使用`define_method`定義一個方法，但不知道是否已經存在具有該名稱的方法。如果已經存在，則會發出警告（如果已啟用）。這並不是什麼大問題，但也不夠乾淨。

方法[`redefine_method`][Module#redefine_method]可以防止此潛在警告，在需要時先刪除現有方法。

如果需要自己定義替換方法（例如使用`delegate`），也可以使用[`silence_redefinition_of_method`][Module#silence_redefinition_of_method]。

注意：定義在`active_support/core_ext/module/redefine_method.rb`中。


`Class`的擴展
---------------------

### 類屬性

#### `class_attribute`

方法[`class_attribute`][Class#class_attribute]聲明一個或多個可繼承的類屬性，可以在層次結構中的任何級別上被覆蓋。

```ruby
class A
  class_attribute :x
end

class B < A; end

class C < B; end

A.x = :a
B.x # => :a
C.x # => :a

B.x = :b
A.x # => :a
C.x # => :b

C.x = :c
A.x # => :a
B.x # => :b
```

例如，`ActionMailer::Base`定義了：

```ruby
class_attribute :default_params
self.default_params = {
  mime_version: "1.0",
  charset: "UTF-8",
  content_type: "text/plain",
  parts_order: [ "text/plain", "text/enriched", "text/html" ]
}.freeze
```

它們也可以在實例級別上訪問和覆蓋。

```ruby
A.x = 1

a1 = A.new
a2 = A.new
a2.x = 2

a1.x # => 1，來自A
a2.x # => 2，在a2中被覆蓋
```

通過將選項`:instance_writer`設置為`false`，可以防止生成寫入器實例方法。

```ruby
module ActiveRecord
  class Base
    class_attribute :table_name_prefix, instance_writer: false, default: "my"
  end
end
```

模型可能會發現這個選項對於防止批量賦值設置屬性很有用。

通過將選項`:instance_reader`設置為`false`，可以防止生成讀取器實例方法。

```ruby
class A
  class_attribute :x, instance_reader: false
end

A.new.x = 1
A.new.x # NoMethodError
```

為了方便起見，`class_attribute`還定義了一個實例謂詞，它是實例讀取器返回的雙重否定。在上面的例子中，它將被稱為`x?`。
當 `:instance_reader` 設為 `false` 時，實例的 predicate 會回傳 `NoMethodError`，就像 reader 方法一樣。

如果不想要實例的 predicate，可以傳遞 `instance_predicate: false`，這樣就不會定義它。

注意：定義在 `active_support/core_ext/class/attribute.rb` 中。

#### `cattr_reader`、`cattr_writer` 和 `cattr_accessor`

宏 [`cattr_reader`][Module#cattr_reader]、[`cattr_writer`][Module#cattr_writer] 和 [`cattr_accessor`][Module#cattr_accessor] 與它們的 `attr_*` 對應物類似，但是針對類別。它們會將類別變數初始化為 `nil`，除非它已經存在，並生成相應的類別方法來存取它：

```ruby
class MysqlAdapter < AbstractAdapter
  # 生成存取 @@emulate_booleans 的類別方法。
  cattr_accessor :emulate_booleans
end
```

此外，你可以傳遞一個區塊給 `cattr_*`，以設定屬性的預設值：

```ruby
class MysqlAdapter < AbstractAdapter
  # 生成存取 @@emulate_booleans 的類別方法，並設定預設值為 true。
  cattr_accessor :emulate_booleans, default: true
end
```

方便起見，也會生成實例方法，它們只是類別屬性的代理。因此，實例可以更改類別屬性，但不能覆蓋它，就像 `class_attribute` 一樣（參見上文）。例如，給定以下程式碼：

```ruby
module ActionView
  class Base
    cattr_accessor :field_error_proc, default: Proc.new { ... }
  end
end
```

我們可以在視圖中存取 `field_error_proc`。

可以通過將 `:instance_reader` 設為 `false` 來阻止生成讀取實例方法，並通過將 `:instance_writer` 設為 `false` 來阻止生成寫入實例方法。可以通過將 `:instance_accessor` 設為 `false` 來阻止生成這兩個方法。在所有情況下，值必須正好是 `false`，而不是任何假值。

```ruby
module A
  class B
    # 不會生成 first_name 的實例讀取方法。
    cattr_accessor :first_name, instance_reader: false
    # 不會生成 last_name= 的實例寫入方法。
    cattr_accessor :last_name, instance_writer: false
    # 不會生成 surname 的實例讀取方法或 surname= 的寫入方法。
    cattr_accessor :surname, instance_accessor: false
  end
end
```

模型可能會發現將 `:instance_accessor` 設為 `false` 是一種防止批量賦值設置屬性的方法。

注意：定義在 `active_support/core_ext/module/attribute_accessors.rb` 中。

### 子類和後代

#### `subclasses`

[`subclasses`][Class#subclasses] 方法返回接收者的子類：

```ruby
class C; end
C.subclasses # => []

class B < C; end
C.subclasses # => [B]

class A < B; end
C.subclasses # => [B]

class D < C; end
C.subclasses # => [B, D]
```

返回這些類的順序是不確定的。

注意：定義在 `active_support/core_ext/class/subclasses.rb` 中。

#### `descendants`

[`descendants`][Class#descendants] 方法返回所有小於接收者的類：

```ruby
class C; end
C.descendants # => []

class B < C; end
C.descendants # => [B]

class A < B; end
C.descendants # => [B, A]

class D < C; end
C.descendants # => [B, A, D]
```

返回這些類的順序是不確定的。

注意：定義在 `active_support/core_ext/class/subclasses.rb` 中。

`String` 的擴展
----------------------

### 輸出安全性

#### 動機

將數據插入 HTML 模板需要額外的注意。例如，你不能直接將 `@review.title` 插入 HTML 頁面中。首先，如果評論標題是 "Flanagan & Matz rules!"，輸出將不符合格式，因為 ampersand 必須被轉義為 "&amp;amp;"。此外，根據應用程序，這可能是一個重大的安全漏洞，因為用戶可以通過設置特製的評論標題來注入惡意 HTML。有關風險的更多信息，請參閱[安全指南](security.html#cross-site-scripting-xss)中有關跨站腳本的部分。
#### 安全字串

Active Support 中有一個 _(html) safe_ 字串的概念。安全字串是一個被標記為可以直接插入 HTML 的字串。無論是否已經進行了轉義，它都是可信任的。

預設情況下，字串被視為 _不安全_：

```ruby
"".html_safe? # => false
```

你可以使用 [`html_safe`][String#html_safe] 方法從給定的字串獲取一個安全字串：

```ruby
s = "".html_safe
s.html_safe? # => true
```

重要的是要理解，`html_safe` 不會進行任何轉義，它只是一個斷言：

```ruby
s = "<script>...</script>".html_safe
s.html_safe? # => true
s            # => "<script>...</script>"
```

確保在特定字串上調用 `html_safe` 是安全的是你的責任。

如果你使用 `concat`/`<<` 或 `+` 在安全字串上進行附加操作，結果將是一個安全字串。不安全的參數將被轉義：

```ruby
"".html_safe + "<" # => "&lt;"
```

安全的參數將直接附加：

```ruby
"".html_safe + "<".html_safe # => "<"
```

這些方法不應該在普通的視圖中使用。不安全的值將自動進行轉義：

```erb
<%= @review.title %> <%# 如果需要，進行轉義是安全的 %>
```

如果要直接插入某個字串，請使用 [`raw`][] 輔助方法，而不是調用 `html_safe`：

```erb
<%= raw @cms.current_template %> <%# 將 @cms.current_template 原樣插入 %>
```

或者，可以使用 `<%==`：

```erb
<%== @cms.current_template %> <%# 將 @cms.current_template 原樣插入 %>
```

`raw` 輔助方法會為你調用 `html_safe`：

```ruby
def raw(stringish)
  stringish.to_s.html_safe
end
```

注意：定義在 `active_support/core_ext/string/output_safety.rb` 中。


#### 轉換

一般來說，除了上面解釋的連接操作，任何可能改變字串的方法都會返回一個不安全的字串。這些方法包括 `downcase`、`gsub`、`strip`、`chomp`、`underscore` 等等。

對於像 `gsub!` 這樣的原地轉換，接收者本身也會變成不安全的。

註：無論轉換是否實際改變了內容，安全標記都會丟失。

#### 轉換和強制轉型

在安全字串上調用 `to_s` 會返回一個安全字串，但是使用 `to_str` 強制轉型會返回一個不安全的字串。

#### 複製

在安全字串上調用 `dup` 或 `clone` 會返回一個安全字串。

### `remove`

[`remove`][String#remove] 方法將刪除所有匹配的模式：

```ruby
"Hello World".remove(/Hello /) # => "World"
```

還有一個具有破壞性的版本 `String#remove!`。

註：定義在 `active_support/core_ext/string/filters.rb` 中。


### `squish`

[`squish`][String#squish] 方法會刪除前後的空白字符，並將連續的空白字符替換為一個空格：

```ruby
" \n  foo\n\r \t bar \n".squish # => "foo bar"
```

還有一個具有破壞性的版本 `String#squish!`。

請注意，它可以處理 ASCII 和 Unicode 的空白字符。

註：定義在 `active_support/core_ext/string/filters.rb` 中。


### `truncate`

[`truncate`][String#truncate] 方法會返回一個在指定 `length` 之後被截斷的副本：

```ruby
"Oh dear! Oh dear! I shall be late!".truncate(20)
# => "Oh dear! Oh dear!..."
```

省略號可以使用 `:omission` 選項自定義：

```ruby
"Oh dear! Oh dear! I shall be late!".truncate(20, omission: '&hellip;')
# => "Oh dear! Oh &hellip;"
```

特別注意，截斷時會考慮省略號的長度。

如果要在自然斷點處截斷字串，可以傳遞 `:separator`：

```ruby
```ruby
"Oh dear! Oh dear! I shall be late!".truncate(18)
# => "Oh dear! Oh dea..."
"Oh dear! Oh dear! I shall be late!".truncate(18, separator: ' ')
# => "Oh dear! Oh..."
```

選項 `:separator` 可以是正則表達式：

```ruby
"Oh dear! Oh dear! I shall be late!".truncate(18, separator: /\s/)
# => "Oh dear! Oh..."
```

在上面的例子中，"dear" 被截斷了，但是 `:separator` 選項阻止了這種情況。

注意：定義在 `active_support/core_ext/string/filters.rb`。


### `truncate_bytes`

方法 [`truncate_bytes`][String#truncate_bytes] 返回一個被截斷到最多 `bytesize` 字節的接收者的副本：

```ruby
"👍👍👍👍".truncate_bytes(15)
# => "👍👍👍…"
```

省略號可以通過 `:omission` 選項自定義：

```ruby
"👍👍👍👍".truncate_bytes(15, omission: "🖖")
# => "👍👍🖖"
```

注意：定義在 `active_support/core_ext/string/filters.rb`。


### `truncate_words`

方法 [`truncate_words`][String#truncate_words] 返回一個在給定的單詞數之後被截斷的接收者的副本：

```ruby
"Oh dear! Oh dear! I shall be late!".truncate_words(4)
# => "Oh dear! Oh dear!..."
```

省略號可以通過 `:omission` 選項自定義：

```ruby
"Oh dear! Oh dear! I shall be late!".truncate_words(4, omission: '&hellip;')
# => "Oh dear! Oh dear!&hellip;"
```

通過 `:separator` 選項將字符串截斷在自然斷點處：

```ruby
"Oh dear! Oh dear! I shall be late!".truncate_words(3, separator: '!')
# => "Oh dear! Oh dear! I shall be late..."
```

選項 `:separator` 可以是正則表達式：

```ruby
"Oh dear! Oh dear! I shall be late!".truncate_words(4, separator: /\s/)
# => "Oh dear! Oh dear!..."
```

注意：定義在 `active_support/core_ext/string/filters.rb`。


### `inquiry`

[`inquiry`][String#inquiry] 方法將字符串轉換為 `StringInquirer` 對象，使相等性檢查更漂亮。

```ruby
"production".inquiry.production? # => true
"active".inquiry.inactive?       # => false
```

注意：定義在 `active_support/core_ext/string/inquiry.rb`。


### `starts_with?` 和 `ends_with?`

Active Support 定義了 `String#start_with?` 和 `String#end_with?` 的第三人稱別名：

```ruby
"foo".starts_with?("f") # => true
"foo".ends_with?("o")   # => true
```

注意：定義在 `active_support/core_ext/string/starts_ends_with.rb`。

### `strip_heredoc`

方法 [`strip_heredoc`][String#strip_heredoc] 去除 heredoc 中的縮進。

例如，在

```ruby
if options[:usage]
  puts <<-USAGE.strip_heredoc
    This command does such and such.

    Supported options are:
      -h         This message
      ...
  USAGE
end
```

中，用戶將看到對齊左邊邊緣的使用消息。

從技術上講，它在整個字符串中尋找最少縮進的行，並刪除相應數量的前導空格。

注意：定義在 `active_support/core_ext/string/strip.rb`。


### `indent`

[`indent`][String#indent] 方法縮進接收者的行：

```ruby
<<EOS.indent(2)
def some_method
  some_code
end
EOS
# =>
  def some_method
    some_code
  end
```

第二個參數 `indent_string` 指定要使用的縮進字符串。默認值為 `nil`，表示方法將根據第一個縮進的行進行猜測，如果沒有，則使用空格。

```ruby
"  foo".indent(2)        # => "    foo"
"foo\n\t\tbar".indent(2) # => "\t\tfoo\n\t\t\t\tbar"
"foo".indent(2, "\t")    # => "\t\tfoo"
```

雖然 `indent_string` 通常是一個空格或制表符，但它可以是任何字符串。

第三個參數 `indent_empty_lines` 是一個標誌，表示是否應該縮進空行。默認值為 false。

```ruby
"foo\n\nbar".indent(2)            # => "  foo\n\n  bar"
"foo\n\nbar".indent(2, nil, true) # => "  foo\n  \n  bar"
```

[`indent!`][String#indent!] 方法在原地執行縮進。

注意：定義在 `active_support/core_ext/string/indent.rb`。
### 存取

#### `at(position)`

[`at`][String#at] 方法返回字符串在位置 `position` 的字符：

```ruby
"hello".at(0)  # => "h"
"hello".at(4)  # => "o"
"hello".at(-1) # => "o"
"hello".at(10) # => nil
```

注意：定义在 `active_support/core_ext/string/access.rb` 中。


#### `from(position)`

[`from`][String#from] 方法返回从位置 `position` 开始的字符串子串：

```ruby
"hello".from(0)  # => "hello"
"hello".from(2)  # => "llo"
"hello".from(-2) # => "lo"
"hello".from(10) # => nil
```

注意：定义在 `active_support/core_ext/string/access.rb` 中。


#### `to(position)`

[`to`][String#to] 方法返回字符串到位置 `position` 的子串：

```ruby
"hello".to(0)  # => "h"
"hello".to(2)  # => "hel"
"hello".to(-2) # => "hell"
"hello".to(10) # => "hello"
```

注意：定义在 `active_support/core_ext/string/access.rb` 中。


#### `first(limit = 1)`

[`first`][String#first] 方法返回字符串的前 `limit` 个字符的子串。

调用 `str.first(n)` 等同于 `str.to(n-1)`，如果 `n` > 0，对于 `n` == 0，返回空字符串。

注意：定义在 `active_support/core_ext/string/access.rb` 中。


#### `last(limit = 1)`

[`last`][String#last] 方法返回字符串的后 `limit` 个字符的子串。

调用 `str.last(n)` 等同于 `str.from(-n)`，如果 `n` > 0，对于 `n` == 0，返回空字符串。

注意：定义在 `active_support/core_ext/string/access.rb` 中。


### 變化形式

#### `pluralize`

[`pluralize`][String#pluralize] 方法返回其接收者的複數形式：

```ruby
"table".pluralize     # => "tables"
"ruby".pluralize      # => "rubies"
"equipment".pluralize # => "equipment"
```

如前面的例子所示，Active Support 知道一些不規則的複數形式和不可數名詞。內建的規則可以在 `config/initializers/inflections.rb` 中擴展。這個文件是默認由 `rails new` 命令生成的，並且有註釋中的指示。

`pluralize` 方法也可以接受一個可選的 `count` 參數。如果 `count == 1`，則返回單數形式。對於任何其他值的 `count`，返回複數形式：

```ruby
"dude".pluralize(0) # => "dudes"
"dude".pluralize(1) # => "dude"
"dude".pluralize(2) # => "dudes"
```

Active Record 使用這個方法來計算對應於模型的默認表名：

```ruby
# active_record/model_schema.rb
def undecorated_table_name(model_name)
  table_name = model_name.to_s.demodulize.underscore
  pluralize_table_names ? table_name.pluralize : table_name
end
```

注意：定义在 `active_support/core_ext/string/inflections.rb` 中。


#### `singularize`

[`singularize`][String#singularize] 方法是 `pluralize` 的反向操作：

```ruby
"tables".singularize    # => "table"
"rubies".singularize    # => "ruby"
"equipment".singularize # => "equipment"
```

關聯使用這個方法來計算對應的默認關聯類名：

```ruby
# active_record/reflection.rb
def derive_class_name
  class_name = name.to_s.camelize
  class_name = class_name.singularize if collection?
  class_name
end
```

注意：定义在 `active_support/core_ext/string/inflections.rb` 中。


#### `camelize`

[`camelize`][String#camelize] 方法返回其接收者的駝峰命名形式：

```ruby
"product".camelize    # => "Product"
"admin_user".camelize # => "AdminUser"
```

作為一個經驗法則，可以將這個方法視為將路徑轉換為 Ruby 類或模塊名稱的方法，其中斜線分隔命名空間：

```ruby
"backoffice/session".camelize # => "Backoffice::Session"
```

例如，Action Pack 使用這個方法來加載提供特定會話存儲的類：

```ruby
# action_controller/metal/session_management.rb
def session_store=(store)
  @@session_store = store.is_a?(Symbol) ?
    ActionDispatch::Session.const_get(store.to_s.camelize) :
    store
end
```

`camelize` 接受一個可選的參數，可以是 `:upper`（默認值）或 `:lower`。使用後者，第一個字母變為小寫：
```ruby
"visual_effect".camelize(:lower) # => "visualEffect"
```

這在計算符合該慣例的語言（例如JavaScript）中的方法名稱時很方便。

INFO: 一般而言，您可以將 `camelize` 視為 `underscore` 的相反操作，但有些情況下並非如此：`"SSLError".underscore.camelize` 會得到 `"SslError"`。為了支援這種情況，Active Support 允許您在 `config/initializers/inflections.rb` 中指定首字母縮寫：

```ruby
ActiveSupport::Inflector.inflections do |inflect|
  inflect.acronym 'SSL'
end

"SSLError".underscore.camelize # => "SSLError"
```

`camelize` 被別名為 [`camelcase`][String#camelcase]。

注意：定義在 `active_support/core_ext/string/inflections.rb` 中。


#### `underscore`

[`underscore`][String#underscore] 方法則相反，將駝峰命名法轉換為路徑：

```ruby
"Product".underscore   # => "product"
"AdminUser".underscore # => "admin_user"
```

同時將 "::" 轉換為 "/":

```ruby
"Backoffice::Session".underscore # => "backoffice/session"
```

並且可以處理以小寫字母開頭的字串：

```ruby
"visualEffect".underscore # => "visual_effect"
```

`underscore` 不接受任何參數。

Rails 使用 `underscore` 來為控制器類獲取小寫名稱：

```ruby
# actionpack/lib/abstract_controller/base.rb
def controller_path
  @controller_path ||= name.delete_suffix("Controller").underscore
end
```

例如，該值是在 `params[:controller]` 中獲取的。

INFO: 一般而言，您可以將 `underscore` 視為 `camelize` 的相反操作，但有些情況下並非如此。例如，`"SSLError".underscore.camelize` 會得到 `"SslError"`。

注意：定義在 `active_support/core_ext/string/inflections.rb` 中。


#### `titleize`

[`titleize`][String#titleize] 方法將接收者中的單詞首字母大寫：

```ruby
"alice in wonderland".titleize # => "Alice In Wonderland"
"fermat's enigma".titleize     # => "Fermat's Enigma"
```

`titleize` 被別名為 [`titlecase`][String#titlecase]。

注意：定義在 `active_support/core_ext/string/inflections.rb` 中。


#### `dasherize`

[`dasherize`][String#dasherize] 方法將接收者中的底線替換為破折號：

```ruby
"name".dasherize         # => "name"
"contact_data".dasherize # => "contact-data"
```

模型的 XML 序列化器使用此方法將節點名稱轉換為破折號：

```ruby
# active_model/serializers/xml.rb
def reformat_name(name)
  name = name.camelize if camelize?
  dasherize? ? name.dasherize : name
end
```

注意：定義在 `active_support/core_ext/string/inflections.rb` 中。


#### `demodulize`

給定一個帶有限定常數名稱的字符串，[`demodulize`][String#demodulize] 返回該常數名稱的最右邊部分：

```ruby
"Product".demodulize                        # => "Product"
"Backoffice::UsersController".demodulize    # => "UsersController"
"Admin::Hotel::ReservationUtils".demodulize # => "ReservationUtils"
"::Inflections".demodulize                  # => "Inflections"
"".demodulize                               # => ""
```

例如，Active Record 使用此方法來計算計數緩存列的名稱：

```ruby
# active_record/reflection.rb
def counter_cache_column
  if options[:counter_cache] == true
    "#{active_record.name.demodulize.underscore.pluralize}_count"
  elsif options[:counter_cache]
    options[:counter_cache]
  end
end
```

注意：定義在 `active_support/core_ext/string/inflections.rb` 中。


#### `deconstantize`

給定一個帶有限定常數引用表達式的字符串，[`deconstantize`][String#deconstantize] 移除最右邊的部分，通常保留常數的容器名稱：

```ruby
"Product".deconstantize                        # => ""
"Backoffice::UsersController".deconstantize    # => "Backoffice"
"Admin::Hotel::ReservationUtils".deconstantize # => "Admin::Hotel"
```

注意：定義在 `active_support/core_ext/string/inflections.rb` 中。


#### `parameterize`

[`parameterize`][String#parameterize] 方法將接收者規範化，以便在漂亮的 URL 中使用。

```ruby
"John Smith".parameterize # => "john-smith"
"Kurt Gödel".parameterize # => "kurt-godel"
```

要保留字符串的大小寫，將 `preserve_case` 參數設置為 true。默認情況下，`preserve_case` 設置為 false。

```ruby
"John Smith".parameterize(preserve_case: true) # => "John-Smith"
"Kurt Gödel".parameterize(preserve_case: true) # => "Kurt-Godel"
```

要使用自定義分隔符，覆蓋 `separator` 參數。

```ruby
"John Smith".parameterize(separator: "_") # => "john_smith"
"Kurt Gödel".parameterize(separator: "_") # => "kurt_godel"
```

注意：在`active_support/core_ext/string/inflections.rb`中定义。

#### `tableize`

方法[`tableize`][String#tableize]是`underscore`后跟`pluralize`。

```ruby
"Person".tableize      # => "people"
"Invoice".tableize     # => "invoices"
"InvoiceLine".tableize # => "invoice_lines"
```

作为一个经验法则，对于简单的情况，`tableize`返回与给定模型对应的表名。实际在Active Record中的实现并不是直接的`tableize`，因为它还会对类名进行去模块化处理，并检查一些可能影响返回字符串的选项。

注意：在`active_support/core_ext/string/inflections.rb`中定义。

#### `classify`

方法[`classify`][String#classify]是`tableize`的反函数。它给出与表名对应的类名：

```ruby
"people".classify        # => "Person"
"invoices".classify      # => "Invoice"
"invoice_lines".classify # => "InvoiceLine"
```

该方法可以理解限定的表名：

```ruby
"highrise_production.companies".classify # => "Company"
```

请注意，`classify`返回一个类名字符串。您可以通过在其上调用`constantize`来获取实际的类对象，下面会解释。

注意：在`active_support/core_ext/string/inflections.rb`中定义。

#### `constantize`

方法[`constantize`][String#constantize]解析其接收者中的常量引用表达式：

```ruby
"Integer".constantize # => Integer

module M
  X = 1
end
"M::X".constantize # => 1
```

如果字符串不是已知常量的名称，或者其内容甚至不是有效的常量名称，`constantize`会引发`NameError`。

`constantize`通过始终从顶级`Object`开始解析常量名称，即使没有前导的"::"，来进行常量名称解析。

```ruby
X = :in_Object
module M
  X = :in_M

  X                 # => :in_M
  "::X".constantize # => :in_Object
  "X".constantize   # => :in_Object (!)
end
```

因此，它通常不等同于Ruby在同一位置上执行的真实常量求值。

Mailer测试用例使用`constantize`从测试类的名称获取正在测试的mailer：

```ruby
# action_mailer/test_case.rb
def determine_default_mailer(name)
  name.delete_suffix("Test").constantize
rescue NameError => e
  raise NonInferrableMailerError.new(name)
end
```

注意：在`active_support/core_ext/string/inflections.rb`中定义。

#### `humanize`

方法[`humanize`][String#humanize]调整属性名称以供最终用户显示。

具体来说，它执行以下转换：

  * 对参数应用人类化规则。
  * 删除前导下划线（如果有）。
  * 如果存在，删除"_id"后缀。
  * 如果有下划线，则将其替换为空格。
  * 除了首字母缩写词外，将所有单词小写。
  * 将第一个单词大写。

可以通过将`:capitalize`选项设置为false（默认为true）来关闭对第一个单词的大写。

```ruby
"name".humanize                         # => "Name"
"author_id".humanize                    # => "Author"
"author_id".humanize(capitalize: false) # => "author"
"comments_count".humanize               # => "Comments count"
"_id".humanize                          # => "Id"
```

如果"SSL"被定义为首字母缩写：

```ruby
'ssl_error'.humanize # => "SSL error"
```

辅助方法`full_messages`使用`humanize`作为回退来包含属性名称：

```ruby
def full_messages
  map { |attribute, message| full_message(attribute, message) }
end

def full_message
  # ...
  attr_name = attribute.to_s.tr('.', '_').humanize
  attr_name = @base.class.human_attribute_name(attribute, default: attr_name)
  # ...
end
```

注意：在`active_support/core_ext/string/inflections.rb`中定义。

#### `foreign_key`

方法[`foreign_key`][String#foreign_key]从类名中获取外键列名。为此，它会去模块化、添加下划线，并添加"_id"：

```ruby
"User".foreign_key           # => "user_id"
"InvoiceLine".foreign_key    # => "invoice_line_id"
"Admin::Session".foreign_key # => "session_id"
```
如果您不想在"_id"中使用底線，請傳遞一個錯誤的參數：

```ruby
"User".foreign_key(false) # => "userid"
```

關聯使用此方法來推斷外鍵，例如`has_one`和`has_many`這樣做：

```ruby
# active_record/associations.rb
foreign_key = options[:foreign_key] || reflection.active_record.name.foreign_key
```

注意：在`active_support/core_ext/string/inflections.rb`中定義。


#### `upcase_first`

方法[`upcase_first`][String#upcase_first]將接收者的第一個字母大寫：

```ruby
"employee salary".upcase_first # => "Employee salary"
"".upcase_first                # => ""
```

注意：在`active_support/core_ext/string/inflections.rb`中定義。


#### `downcase_first`

方法[`downcase_first`][String#downcase_first]將接收者的第一個字母轉換為小寫：

```ruby
"If I had read Alice in Wonderland".downcase_first # => "if I had read Alice in Wonderland"
"".downcase_first                                  # => ""
```

注意：在`active_support/core_ext/string/inflections.rb`中定義。


### 轉換

#### `to_date`、`to_time`、`to_datetime`

方法[`to_date`][String#to_date]、[`to_time`][String#to_time]和[`to_datetime`][String#to_datetime]基本上是對`Date._parse`的方便封裝：

```ruby
"2010-07-27".to_date              # => Tue, 27 Jul 2010
"2010-07-27 23:37:00".to_time     # => 2010-07-27 23:37:00 +0200
"2010-07-27 23:37:00".to_datetime # => Tue, 27 Jul 2010 23:37:00 +0000
```

`to_time`接收一個可選的參數`:utc`或`:local`，用於指示您希望時間在哪個時區：

```ruby
"2010-07-27 23:42:00".to_time(:utc)   # => 2010-07-27 23:42:00 UTC
"2010-07-27 23:42:00".to_time(:local) # => 2010-07-27 23:42:00 +0200
```

默認值為`:local`。

請參閱`Date._parse`的文檔以獲取更多詳細信息。

INFO：它們三個都對於空接收者返回`nil`。

注意：在`active_support/core_ext/string/conversions.rb`中定義。


`Symbol`的擴展
----------------------

### `starts_with?`和`ends_with?`

Active Support定義了`Symbol#start_with?`和`Symbol#end_with?`的第三人稱別名：

```ruby
:foo.starts_with?("f") # => true
:foo.ends_with?("o")   # => true
```

注意：在`active_support/core_ext/symbol/starts_ends_with.rb`中定義。

`Numeric`的擴展
-----------------------

### Bytes

所有數字都會響應這些方法：

* [`bytes`][Numeric#bytes]
* [`kilobytes`][Numeric#kilobytes]
* [`megabytes`][Numeric#megabytes]
* [`gigabytes`][Numeric#gigabytes]
* [`terabytes`][Numeric#terabytes]
* [`petabytes`][Numeric#petabytes]
* [`exabytes`][Numeric#exabytes]

它們返回相應的字節數，使用1024的換算因子：

```ruby
2.kilobytes   # => 2048
3.megabytes   # => 3145728
3.5.gigabytes # => 3758096384.0
-4.exabytes   # => -4611686018427387904
```

單數形式被別名，因此您可以這樣說：

```ruby
1.megabyte # => 1048576
```

注意：在`active_support/core_ext/numeric/bytes.rb`中定義。


### Time

以下方法：

* [`seconds`][Numeric#seconds]
* [`minutes`][Numeric#minutes]
* [`hours`][Numeric#hours]
* [`days`][Numeric#days]
* [`weeks`][Numeric#weeks]
* [`fortnights`][Numeric#fortnights]

使時間聲明和計算成為可能，例如`45.minutes + 2.hours + 4.weeks`。它們的返回值也可以添加到或從時間對象中減去。

這些方法可以與[`from_now`][Duration#from_now]、[`ago`][Duration#ago]等結合使用，進行精確的日期計算。例如：

```ruby
# 等同於 Time.current.advance(days: 1)
1.day.from_now

# 等同於 Time.current.advance(weeks: 2)
2.weeks.from_now

# 等同於 Time.current.advance(days: 4, weeks: 5)
(4.days + 5.weeks).from_now
```

警告：對於其他持續時間，請參閱對`Integer`的時間擴展。

注意：在`active_support/core_ext/numeric/time.rb`中定義。


### 格式化

使數字以各種方式進行格式化。

將數字作為電話號碼的字符串表示形式：

```ruby
5551234.to_fs(:phone)
# => 555-1234
1235551234.to_fs(:phone)
# => 123-555-1234
1235551234.to_fs(:phone, area_code: true)
# => (123) 555-1234
1235551234.to_fs(:phone, delimiter: " ")
# => 123 555 1234
1235551234.to_fs(:phone, area_code: true, extension: 555)
# => (123) 555-1234 x 555
1235551234.to_fs(:phone, country_code: 1)
# => +1-123-555-1234
```

將數字作為貨幣的字符串表示形式：

```ruby
1234567890.50.to_fs(:currency)                 # => $1,234,567,890.50
1234567890.506.to_fs(:currency)                # => $1,234,567,890.51
1234567890.506.to_fs(:currency, precision: 3)  # => $1,234,567,890.506
```
將數字以百分比的形式轉換為字符串表示：

```ruby
100.to_fs(:percentage)
# => 100.000%
100.to_fs(:percentage, precision: 0)
# => 100%
1000.to_fs(:percentage, delimiter: '.', separator: ',')
# => 1.000,000%
302.24398923423.to_fs(:percentage, precision: 5)
# => 302.24399%
```

將數字以分隔形式轉換為字符串表示：

```ruby
12345678.to_fs(:delimited)                     # => 12,345,678
12345678.05.to_fs(:delimited)                  # => 12,345,678.05
12345678.to_fs(:delimited, delimiter: ".")     # => 12.345.678
12345678.to_fs(:delimited, delimiter: ",")     # => 12,345,678
12345678.05.to_fs(:delimited, separator: " ")  # => 12,345,678 05
```

將數字四捨五入到指定的精度：

```ruby
111.2345.to_fs(:rounded)                     # => 111.235
111.2345.to_fs(:rounded, precision: 2)       # => 111.23
13.to_fs(:rounded, precision: 5)             # => 13.00000
389.32314.to_fs(:rounded, precision: 0)      # => 389
111.2345.to_fs(:rounded, significant: true)  # => 111
```

將數字以人類可讀的字節數形式轉換為字符串表示：

```ruby
123.to_fs(:human_size)                  # => 123 Bytes
1234.to_fs(:human_size)                 # => 1.21 KB
12345.to_fs(:human_size)                # => 12.1 KB
1234567.to_fs(:human_size)              # => 1.18 MB
1234567890.to_fs(:human_size)           # => 1.15 GB
1234567890123.to_fs(:human_size)        # => 1.12 TB
1234567890123456.to_fs(:human_size)     # => 1.1 PB
1234567890123456789.to_fs(:human_size)  # => 1.07 EB
```

將數字以人類可讀的詞語形式轉換為字符串表示：

```ruby
123.to_fs(:human)               # => "123"
1234.to_fs(:human)              # => "1.23 Thousand"
12345.to_fs(:human)             # => "12.3 Thousand"
1234567.to_fs(:human)           # => "1.23 Million"
1234567890.to_fs(:human)        # => "1.23 Billion"
1234567890123.to_fs(:human)     # => "1.23 Trillion"
1234567890123456.to_fs(:human)  # => "1.23 Quadrillion"
```

注意：定義在 `active_support/core_ext/numeric/conversions.rb` 中。

`Integer` 的擴展
-----------------------

### `multiple_of?`

[`multiple_of?`][Integer#multiple_of?] 方法用於測試一個整數是否為另一個整數的倍數：

```ruby
2.multiple_of?(1) # => true
1.multiple_of?(2) # => false
```

注意：定義在 `active_support/core_ext/integer/multiple.rb` 中。


### `ordinal`

[`ordinal`][Integer#ordinal] 方法返回與接收方整數對應的序數後綴字符串：

```ruby
1.ordinal    # => "st"
2.ordinal    # => "nd"
53.ordinal   # => "rd"
2009.ordinal # => "th"
-21.ordinal  # => "st"
-134.ordinal # => "th"
```

注意：定義在 `active_support/core_ext/integer/inflections.rb` 中。


### `ordinalize`

[`ordinalize`][Integer#ordinalize] 方法返回與接收方整數對應的序數字符串。請注意，`ordinal` 方法僅返回後綴字符串。

```ruby
1.ordinalize    # => "1st"
2.ordinalize    # => "2nd"
53.ordinalize   # => "53rd"
2009.ordinalize # => "2009th"
-21.ordinalize  # => "-21st"
-134.ordinalize # => "-134th"
```

注意：定義在 `active_support/core_ext/integer/inflections.rb` 中。


### Time

以下方法：

* [`months`][Integer#months]
* [`years`][Integer#years]

允許時間的聲明和計算，例如 `4.months + 5.years`。它們的返回值也可以添加到或從時間對象中減去。

這些方法可以與 [`from_now`][Duration#from_now]、[`ago`][Duration#ago] 等結合使用，進行精確的日期計算。例如：

```ruby
# 等同於 Time.current.advance(months: 1)
1.month.from_now

# 等同於 Time.current.advance(years: 2)
2.years.from_now

# 等同於 Time.current.advance(months: 4, years: 5)
(4.months + 5.years).from_now
```

警告：對於其他持續時間，請參考對 `Numeric` 的時間擴展。

注意：定義在 `active_support/core_ext/integer/time.rb` 中。


`BigDecimal` 的擴展
--------------------------

### `to_s`

`to_s` 方法提供了默認的 "F" 類型。這意味著對 `to_s` 的簡單調用將得到浮點表示，而不是工程表示法：

```ruby
BigDecimal(5.00, 6).to_s       # => "5.0"
```

仍然支持工程表示法：

```ruby
BigDecimal(5.00, 6).to_s("e")  # => "0.5E1"
```

`Enumerable` 的擴展
--------------------------

### `sum`

[`sum`][Enumerable#sum] 方法將可枚舉對象的元素相加：
```ruby
[1, 2, 3].sum # => 6
(1..100).sum  # => 5050
```

加法只假設元素能夠回應 `+`：

```ruby
[[1, 2], [2, 3], [3, 4]].sum    # => [1, 2, 2, 3, 3, 4]
%w(foo bar baz).sum             # => "foobarbaz"
{ a: 1, b: 2, c: 3 }.sum          # => [:a, 1, :b, 2, :c, 3]
```

預設情況下，空集合的總和為零，但這是可以自定義的：

```ruby
[].sum    # => 0
[].sum(1) # => 1
```

如果給定了一個塊，`sum` 將成為一個迭代器，它會遍歷集合的元素並對返回的值進行求和：

```ruby
(1..5).sum { |n| n * 2 } # => 30
[2, 4, 6, 8, 10].sum    # => 30
```

空接收者的總和也可以以這種形式進行自定義：

```ruby
[].sum(1) { |n| n**3 } # => 1
```

注意：定義在 `active_support/core_ext/enumerable.rb` 中。


### `index_by`

方法 [`index_by`][Enumerable#index_by] 通過某個鍵將可枚舉對象的元素生成一個哈希表。

它遍歷集合並將每個元素傳遞給塊。元素將以塊返回的值作為鍵：

```ruby
invoices.index_by(&:number)
# => {'2009-032' => <Invoice ...>, '2009-008' => <Invoice ...>, ...}
```

警告：鍵通常應該是唯一的。如果塊對不同的元素返回相同的值，則不會為該鍵構建集合。最後一個項目將獲勝。

注意：定義在 `active_support/core_ext/enumerable.rb` 中。


### `index_with`

方法 [`index_with`][Enumerable#index_with] 生成一個哈希表，其中可枚舉對象的元素作為鍵。值可以是傳遞的默認值或塊返回的值。

```ruby
post = Post.new(title: "hey there", body: "what's up?")

%i( title body ).index_with { |attr_name| post.public_send(attr_name) }
# => { title: "hey there", body: "what's up?" }

WEEKDAYS.index_with(Interval.all_day)
# => { monday: [ 0, 1440 ], … }
```

注意：定義在 `active_support/core_ext/enumerable.rb` 中。


### `many?`

方法 [`many?`][Enumerable#many?] 是 `collection.size > 1` 的簡寫：

```erb
<% if pages.many? %>
  <%= pagination_links %>
<% end %>
```

如果給定了可選的塊，`many?` 只會考慮返回 true 的那些元素：

```ruby
@see_more = videos.many? { |video| video.category == params[:category] }
```

注意：定義在 `active_support/core_ext/enumerable.rb` 中。


### `exclude?`

預測方法 [`exclude?`][Enumerable#exclude?] 測試給定的對象是否**不屬於**集合。它是內建 `include?` 的否定：

```ruby
to_visit << node if visited.exclude?(node)
```

注意：定義在 `active_support/core_ext/enumerable.rb` 中。


### `including`

方法 [`including`][Enumerable#including] 返回一個包含傳遞的元素的新的可枚舉對象：

```ruby
[ 1, 2, 3 ].including(4, 5)                    # => [ 1, 2, 3, 4, 5 ]
["David", "Rafael"].including %w[ Aaron Todd ] # => ["David", "Rafael", "Aaron", "Todd"]
```

注意：定義在 `active_support/core_ext/enumerable.rb` 中。


### `excluding`

方法 [`excluding`][Enumerable#excluding] 返回一個刪除了指定元素的可枚舉對象的副本：

```ruby
["David", "Rafael", "Aaron", "Todd"].excluding("Aaron", "Todd") # => ["David", "Rafael"]
```

`excluding` 的別名是 [`without`][Enumerable#without]。

注意：定義在 `active_support/core_ext/enumerable.rb` 中。


### `pluck`

方法 [`pluck`][Enumerable#pluck] 從每個元素中提取給定的鍵：

```ruby
[{ name: "David" }, { name: "Rafael" }, { name: "Aaron" }].pluck(:name) # => ["David", "Rafael", "Aaron"]
[{ id: 1, name: "David" }, { id: 2, name: "Rafael" }].pluck(:id, :name) # => [[1, "David"], [2, "Rafael"]]
```

注意：定義在 `active_support/core_ext/enumerable.rb` 中。

### `pick`

[`pick`][Enumerable#pick] 方法從第一個元素中提取指定的鍵：

```ruby
[{ name: "David" }, { name: "Rafael" }, { name: "Aaron" }].pick(:name) # => "David"
[{ id: 1, name: "David" }, { id: 2, name: "Rafael" }].pick(:id, :name) # => [1, "David"]
```

注意：定義在 `active_support/core_ext/enumerable.rb` 中。

陣列的擴充
---------------------

### 存取

Active Support 擴充了陣列的 API，以便更輕鬆地存取它們。例如，[`to`][Array#to] 方法返回從開頭到指定索引的子陣列：

```ruby
%w(a b c d).to(2) # => ["a", "b", "c"]
[].to(7)          # => []
```

同樣地，[`from`][Array#from] 方法返回從指定索引到結尾的尾部。如果索引大於陣列的長度，則返回一個空陣列。

```ruby
%w(a b c d).from(2)  # => ["c", "d"]
%w(a b c d).from(10) # => []
[].from(0)           # => []
```

[`including`][Array#including] 方法返回一個包含指定元素的新陣列：

```ruby
[ 1, 2, 3 ].including(4, 5)          # => [ 1, 2, 3, 4, 5 ]
[ [ 0, 1 ] ].including([ [ 1, 0 ] ]) # => [ [ 0, 1 ], [ 1, 0 ] ]
```

[`excluding`][Array#excluding] 方法返回一個不包含指定元素的陣列副本。
這是對 `Enumerable#excluding` 的優化，出於性能原因使用 `Array#-` 而不是 `Array#reject`。

```ruby
["David", "Rafael", "Aaron", "Todd"].excluding("Aaron", "Todd") # => ["David", "Rafael"]
[ [ 0, 1 ], [ 1, 0 ] ].excluding([ [ 1, 0 ] ])                  # => [ [ 0, 1 ] ]
```

[`second`][Array#second]、[`third`][Array#third]、[`fourth`][Array#fourth] 和 [`fifth`][Array#fifth] 方法返回對應的元素，[`second_to_last`][Array#second_to_last] 和 [`third_to_last`][Array#third_to_last] 也是如此（`first` 和 `last` 是內建的）。感謝社會智慧和積極建設，[`forty_two`][Array#forty_two] 也可用。

```ruby
%w(a b c d).third # => "c"
%w(a b c d).fifth # => nil
```

注意：定義在 `active_support/core_ext/array/access.rb` 中。

### 提取

[`extract!`][Array#extract!] 方法移除並返回使區塊返回 true 的元素。
如果沒有給定區塊，則返回一個 Enumerator。

```ruby
numbers = [0, 1, 2, 3, 4, 5, 6, 7, 8, 9]
odd_numbers = numbers.extract! { |number| number.odd? } # => [1, 3, 5, 7, 9]
numbers # => [0, 2, 4, 6, 8]
```

注意：定義在 `active_support/core_ext/array/extract.rb` 中。

### 選項提取

當方法調用的最後一個參數是一個哈希時，除了可能是一個 `&block` 參數外，Ruby 允許省略括號：

```ruby
User.exists?(email: params[:email])
```

這種語法糖在 Rails 中被廣泛使用，以避免在有太多位置參數的情況下使用位置參數，而是提供模擬命名參數的接口。特別是在選項方面，使用尾隨哈希非常慣用。

然而，如果一個方法期望可變數量的參數並在其聲明中使用 `*`，這樣的選項哈希最終成為參數陣列的一個項目，失去了它的作用。

在這些情況下，你可以使用 [`extract_options!`][Array#extract_options!] 給予選項哈希一個特殊的處理。這個方法檢查陣列的最後一個項目的類型。如果它是一個哈希，則將其彈出並返回，否則返回一個空哈希。
讓我們以 `caches_action` 控制器宏的定義為例：

```ruby
def caches_action(*actions)
  return unless cache_configured?
  options = actions.extract_options!
  # ...
end
```

這個方法接收任意數量的動作名稱，以及一個可選的選項哈希作為最後一個參數。通過調用 `extract_options!`，你可以獲取選項哈希並從 `actions` 中刪除它，這樣做簡單明了。

注意：定義在 `active_support/core_ext/array/extract_options.rb` 中。


### 轉換

#### `to_sentence`

方法 [`to_sentence`][Array#to_sentence] 將數組轉換為一個包含列舉其項目的句子的字符串：

```ruby
%w().to_sentence                # => ""
%w(Earth).to_sentence           # => "Earth"
%w(Earth Wind).to_sentence      # => "Earth and Wind"
%w(Earth Wind Fire).to_sentence # => "Earth, Wind, and Fire"
```

該方法接受三個選項：

* `:two_words_connector`：用於長度為2的數組。默認值為 " and "。
* `:words_connector`：用於連接3個或更多元素的數組的元素，除了最後兩個。默認值為 ", "。
* `:last_word_connector`：用於連接3個或更多元素的數組的最後幾個項目。默認值為 ", and "。

這些選項的默認值可以本地化，它們的鍵是：

| 選項                   | I18n 鍵                              |
| ---------------------- | ----------------------------------- |
| `:two_words_connector` | `support.array.two_words_connector` |
| `:words_connector`     | `support.array.words_connector`     |
| `:last_word_connector` | `support.array.last_word_connector` |

注意：定義在 `active_support/core_ext/array/conversions.rb` 中。


#### `to_fs`

方法 [`to_fs`][Array#to_fs] 默認情況下與 `to_s` 類似。

然而，如果數組包含對 `id` 有反應的項目，則可以將符號 `:db` 作為參數傳遞。這通常與 Active Record 對象的集合一起使用。返回的字符串如下：

```ruby
[].to_fs(:db)            # => "null"
[user].to_fs(:db)        # => "8456"
invoice.lines.to_fs(:db) # => "23,567,556,12"
```

上面示例中的整數應該來自於對 `id` 的相應調用。

注意：定義在 `active_support/core_ext/array/conversions.rb` 中。


#### `to_xml`

方法 [`to_xml`][Array#to_xml] 返回一個包含其接收者的 XML 表示的字符串：

```ruby
Contributor.limit(2).order(:rank).to_xml
# =>
# <?xml version="1.0" encoding="UTF-8"?>
# <contributors type="array">
#   <contributor>
#     <id type="integer">4356</id>
#     <name>Jeremy Kemper</name>
#     <rank type="integer">1</rank>
#     <url-id>jeremy-kemper</url-id>
#   </contributor>
#   <contributor>
#     <id type="integer">4404</id>
#     <name>David Heinemeier Hansson</name>
#     <rank type="integer">2</rank>
#     <url-id>david-heinemeier-hansson</url-id>
#   </contributor>
# </contributors>
```

為此，它依次將 `to_xml` 發送給每個項目，並將結果收集在一個根節點下。所有項目都必須響應 `to_xml`，否則將引發異常。

默認情況下，根元素的名稱是第一個項目的類的底線和破折號化的復數形式，前提是其餘元素屬於該類型（使用 `is_a?` 檢查），並且它們不是哈希。在上面的示例中，這是 "contributors"。

如果有任何元素不屬於第一個元素的類型，根節點變為 "objects"：

```ruby
[Contributor.first, Commit.first].to_xml
# =>
# <?xml version="1.0" encoding="UTF-8"?>
# <objects type="array">
#   <object>
#     <id type="integer">4583</id>
#     <name>Aaron Batalion</name>
#     <rank type="integer">53</rank>
#     <url-id>aaron-batalion</url-id>
#   </object>
#   <object>
#     <author>Joshua Peek</author>
#     <authored-timestamp type="datetime">2009-09-02T16:44:36Z</authored-timestamp>
#     <branch>origin/master</branch>
#     <committed-timestamp type="datetime">2009-09-02T16:44:36Z</committed-timestamp>
#     <committer>Joshua Peek</committer>
#     <git-show nil="true"></git-show>
#     <id type="integer">190316</id>
#     <imported-from-svn type="boolean">false</imported-from-svn>
#     <message>Kill AMo observing wrap_with_notifications since ARes was only using it</message>
#     <sha1>723a47bfb3708f968821bc969a9a3fc873a3ed58</sha1>
#   </object>
# </objects>
```
如果接收者是一個哈希數組，則根元素默認也是“objects”：

```ruby
[{ a: 1, b: 2 }, { c: 3 }].to_xml
# =>
# <?xml version="1.0" encoding="UTF-8"?>
# <objects type="array">
#   <object>
#     <b type="integer">2</b>
#     <a type="integer">1</a>
#   </object>
#   <object>
#     <c type="integer">3</c>
#   </object>
# </objects>
```

警告。如果集合為空，則根元素默認為“nil-classes”。這是一個陷阱，例如上面的貢獻者列表的根元素如果集合為空，不是“contributors”，而是“nil-classes”。您可以使用“:root”選項來確保一致的根元素。

子節點的名稱默認情況下是根節點的單數形式。在上面的示例中，我們看到了“contributor”和“object”。選項“:children”允許您設置這些節點名稱。

默認的XML構建器是`Builder::XmlMarkup`的新實例。您可以通過“:builder”選項配置自己的構建器。該方法還接受像“:dasherize”和其他選項，它們被轉發給構建器：

```ruby
Contributor.limit(2).order(:rank).to_xml(skip_types: true)
# =>
# <?xml version="1.0" encoding="UTF-8"?>
# <contributors>
#   <contributor>
#     <id>4356</id>
#     <name>Jeremy Kemper</name>
#     <rank>1</rank>
#     <url-id>jeremy-kemper</url-id>
#   </contributor>
#   <contributor>
#     <id>4404</id>
#     <name>David Heinemeier Hansson</name>
#     <rank>2</rank>
#     <url-id>david-heinemeier-hansson</url-id>
#   </contributor>
# </contributors>
```

注意：定義在`active_support/core_ext/array/conversions.rb`中。


### 包裝

方法[`Array.wrap`][Array.wrap]將其參數包裝在數組中，除非它已經是數組（或類似數組）。

具體來說：

* 如果參數為`nil`，則返回一個空數組。
* 否則，如果參數響應`to_ary`，則調用它，如果`to_ary`的值不為`nil`，則返回該值。
* 否則，返回一個以參數作為其單個元素的數組。

```ruby
Array.wrap(nil)       # => []
Array.wrap([1, 2, 3]) # => [1, 2, 3]
Array.wrap(0)         # => [0]
```

此方法的目的類似於`Kernel#Array`，但有一些區別：

* 如果參數響應`to_ary`，則調用該方法。`Kernel#Array`繼續嘗試`to_a`，如果返回的值為`nil`，但`Array.wrap`立即返回一個以參數作為其單個元素的數組。
* 如果`to_ary`返回的值既不是`nil`也不是`Array`對象，`Kernel#Array`會引發異常，而`Array.wrap`不會，它只是返回該值。
* 如果參數不響應`to_ary`，則不會調用`to_a`，而是返回一個以參數作為其單個元素的數組。

對於某些可枚舉對象，特別值得比較的是最後一點：

```ruby
Array.wrap(foo: :bar) # => [{:foo=>:bar}]
Array(foo: :bar)      # => [[:foo, :bar]]
```

還有一個使用展開運算符的相關慣用語法：

```ruby
[*object]
```

注意：定義在`active_support/core_ext/array/wrap.rb`中。


### 複製

方法[`Array#deep_dup`][Array#deep_dup]使用Active Support方法`Object#deep_dup`遞歸地複製自身和內部的所有對象。它的工作方式類似於`Array#map`，將`deep_dup`方法發送給每個內部對象。

```ruby
array = [1, [2, 3]]
dup = array.deep_dup
dup[1][2] = 4
array[1][2] == nil   # => true
```

注意：定義在`active_support/core_ext/object/deep_dup.rb`中。
### 分組

#### `in_groups_of(number, fill_with = nil)`

方法 [`in_groups_of`][Array#in_groups_of] 將一個陣列分成連續的一組，每組的大小為指定的大小。它返回一個包含這些組的陣列：

```ruby
[1, 2, 3].in_groups_of(2) # => [[1, 2], [3, nil]]
```

如果傳遞了一個區塊，則會依次返回這些組：

```html+erb
<% sample.in_groups_of(3) do |a, b, c| %>
  <tr>
    <td><%= a %></td>
    <td><%= b %></td>
    <td><%= c %></td>
  </tr>
<% end %>
```

第一個例子展示了 `in_groups_of` 如何使用足夠多的 `nil` 元素填充最後一組，以達到指定的大小。您可以使用第二個可選參數來更改此填充值：

```ruby
[1, 2, 3].in_groups_of(2, 0) # => [[1, 2], [3, 0]]
```

您可以通過傳遞 `false` 來告訴方法不要填充最後一組：

```ruby
[1, 2, 3].in_groups_of(2, false) # => [[1, 2], [3]]
```

因此，`false` 不能用作填充值。

注意：定義在 `active_support/core_ext/array/grouping.rb`。


#### `in_groups(number, fill_with = nil)`

方法 [`in_groups`][Array#in_groups] 將一個陣列分成指定數量的組。該方法返回一個包含這些組的陣列：

```ruby
%w(1 2 3 4 5 6 7).in_groups(3)
# => [["1", "2", "3"], ["4", "5", nil], ["6", "7", nil]]
```

如果傳遞了一個區塊，則會依次返回這些組：

```ruby
%w(1 2 3 4 5 6 7).in_groups(3) { |group| p group }
["1", "2", "3"]
["4", "5", nil]
["6", "7", nil]
```

上面的例子顯示了 `in_groups` 如何根據需要使用尾部的 `nil` 元素填充某些組。每個組最多只能有一個額外的元素，如果有的話，則為最右邊的元素。並且具有這些額外元素的組始終是最後一個組。

您可以使用第二個可選參數來更改此填充值：

```ruby
%w(1 2 3 4 5 6 7).in_groups(3, "0")
# => [["1", "2", "3"], ["4", "5", "0"], ["6", "7", "0"]]
```

您可以通過傳遞 `false` 來告訴方法不要填充較小的組：

```ruby
%w(1 2 3 4 5 6 7).in_groups(3, false)
# => [["1", "2", "3"], ["4", "5"], ["6", "7"]]
```

因此，`false` 不能用作填充值。

注意：定義在 `active_support/core_ext/array/grouping.rb`。


#### `split(value = nil)`

方法 [`split`][Array#split] 通過分隔符將一個陣列分割並返回結果的塊。

如果傳遞了一個區塊，則分隔符是陣列中使區塊返回 true 的元素：

```ruby
(-5..5).to_a.split { |i| i.multiple_of?(4) }
# => [[-5], [-3, -2, -1], [1, 2, 3], [5]]
```

否則，接收到的參數值（默認為 `nil`）是分隔符：

```ruby
[0, 1, -5, 1, 1, "foo", "bar"].split(1)
# => [[0], [-5], [], ["foo", "bar"]]
```

提示：觀察前面的例子，連續的分隔符會導致空陣列。

注意：定義在 `active_support/core_ext/array/grouping.rb`。


`Hash` 的擴展
--------------------

### 轉換

#### `to_xml`

方法 [`to_xml`][Hash#to_xml] 返回一個包含其接收者的 XML 表示的字符串：

```ruby
{ foo: 1, bar: 2 }.to_xml
# =>
# <?xml version="1.0" encoding="UTF-8"?>
# <hash>
#   <foo type="integer">1</foo>
#   <bar type="integer">2</bar>
# </hash>
```
為了做到這一點，該方法會遍歷這些鍵值對並建立依賴於_values_的節點。給定一對`key`和`value`：

* 如果`value`是一個哈希，則使用`key`作為`:root`進行遞歸調用。

* 如果`value`是一個數組，則使用`key`作為`:root`，並將`key`的單數形式作為`:children`進行遞歸調用。

* 如果`value`是一個可調用對象，則它必須接受一個或兩個參數。根據參數的個數，調用可調用對象時，將`options`哈希作為第一個參數，並將`key`的單數形式作為第二個參數。其返回值將成為一個新的節點。

* 如果`value`響應`to_xml`方法，則使用`key`作為`:root`進行調用。

* 否則，創建一個以`key`為標籤的節點，其文本節點的字符串表示形式為`value`。如果`value`為`nil`，則添加一個名為"nil"且值為"true"的屬性。除非存在且為true的選項`:skip_types`，否則還將根據以下映射添加一個名為"type"的屬性：

```ruby
XML_TYPE_NAMES = {
  "Symbol"     => "symbol",
  "Integer"    => "integer",
  "BigDecimal" => "decimal",
  "Float"      => "float",
  "TrueClass"  => "boolean",
  "FalseClass" => "boolean",
  "Date"       => "date",
  "DateTime"   => "datetime",
  "Time"       => "datetime"
}
```

默認情況下，根節點為"hash"，但可以通過`:root`選項進行配置。

默認的XML構建器是`Builder::XmlMarkup`的新實例。您可以使用`:builder`選項配置自己的構建器。該方法還接受像`:dasherize`和其他選項，它們將被轉發給構建器。

注意：定義在`active_support/core_ext/hash/conversions.rb`中。


### 合併

Ruby有一個內置的方法`Hash#merge`，用於合併兩個哈希：

```ruby
{ a: 1, b: 1 }.merge(a: 0, c: 2)
# => {:a=>0, :b=>1, :c=>2}
```

Active Support定義了幾種更方便的合併哈希的方式。

#### `reverse_merge`和`reverse_merge!`

在`merge`中，如果哈希的鍵發生碰撞，則使用參數中的哈希中的鍵。您可以使用以下簡潔的方式支持具有默認值的選項哈希：

```ruby
options = { length: 30, omission: "..." }.merge(options)
```

Active Support定義了[`reverse_merge`][Hash#reverse_merge]，以便您可以使用以下替代記法：

```ruby
options = options.reverse_merge(length: 30, omission: "...")
```

還有一個帶有驚嘆號的版本[`reverse_merge!`][Hash#reverse_merge!]，它在原地執行合併：

```ruby
options.reverse_merge!(length: 30, omission: "...")
```

警告。請注意，`reverse_merge!`可能會更改調用者的哈希，這可能是好事，也可能不是好事。

注意：定義在`active_support/core_ext/hash/reverse_merge.rb`中。


#### `reverse_update`

方法[`reverse_update`][Hash#reverse_update]是`reverse_merge!`的別名，如上所述。

警告。請注意，`reverse_update`沒有驚嘆號。

注意：定義在`active_support/core_ext/hash/reverse_merge.rb`中。


#### `deep_merge`和`deep_merge!`

如前面的示例所示，如果一個鍵在兩個哈希中都找到，則參數中的哈希中的值將優先。

Active Support定義了[`Hash#deep_merge`][Hash#deep_merge]。在深度合併中，如果一個鍵在兩個哈希中都找到，且它們的值都是哈希，則它們的合併將成為結果哈希中的值：

```ruby
{ a: { b: 1 } }.deep_merge(a: { c: 2 })
# => {:a=>{:b=>1, :c=>2}}
```
方法[`deep_merge!`][Hash#deep_merge!]在原地進行深度合併。

注意：定義在`active_support/core_ext/hash/deep_merge.rb`中。


### 深度複製

方法[`Hash#deep_dup`][Hash#deep_dup]使用Active Support方法`Object#deep_dup`對自身以及所有鍵和值進行遞歸複製。它的工作方式類似於`Enumerator#each_with_object`，將`deep_dup`方法發送給每對鍵值。

```ruby
hash = { a: 1, b: { c: 2, d: [3, 4] } }

dup = hash.deep_dup
dup[:b][:e] = 5
dup[:b][:d] << 5

hash[:b][:e] == nil      # => true
hash[:b][:d] == [3, 4]   # => true
```

注意：定義在`active_support/core_ext/object/deep_dup.rb`中。


### 鍵的操作

#### `except`和`except!`

方法[`except`][Hash#except]返回一個刪除了參數列表中存在的鍵的哈希：

```ruby
{ a: 1, b: 2 }.except(:a) # => {:b=>2}
```

如果接收者響應`convert_key`，則在每個參數上調用該方法。這使得`except`能夠與具有無差別訪問的哈希良好配合，例如：

```ruby
{ a: 1 }.with_indifferent_access.except(:a)  # => {}
{ a: 1 }.with_indifferent_access.except("a") # => {}
```

還有一個原地變體[`except!`][Hash#except!]，它在原地刪除鍵。

注意：定義在`active_support/core_ext/hash/except.rb`中。


#### `stringify_keys`和`stringify_keys!`

方法[`stringify_keys`][Hash#stringify_keys]返回一個鍵為接收者鍵的字符串版本的哈希。它通過對鍵發送`to_s`來實現：

```ruby
{ nil => nil, 1 => 1, a: :a }.stringify_keys
# => {"" => nil, "1" => 1, "a" => :a}
```

在鍵碰撞的情況下，值將是最近插入哈希中的值：

```ruby
{ "a" => 1, a: 2 }.stringify_keys
# 結果將是
# => {"a"=>2}
```

這個方法可能很有用，例如可以輕鬆接受符號和字符串作為選項。例如，`ActionView::Helpers::FormHelper`定義了：

```ruby
def to_check_box_tag(options = {}, checked_value = "1", unchecked_value = "0")
  options = options.stringify_keys
  options["type"] = "checkbox"
  # ...
end
```

第二行可以安全地訪問"類型"鍵，並允許用戶傳遞`：type`或"type"。

還有一個原地變體[`stringify_keys!`][Hash#stringify_keys!]，它在原地將鍵轉為字符串。

此外，還可以使用[`deep_stringify_keys`][Hash#deep_stringify_keys]和[`deep_stringify_keys!`][Hash#deep_stringify_keys!]將給定哈希中的所有鍵以及其中嵌套的所有哈希轉為字符串。結果的示例如下：

```ruby
{ nil => nil, 1 => 1, nested: { a: 3, 5 => 5 } }.deep_stringify_keys
# => {""=>nil, "1"=>1, "nested"=>{"a"=>3, "5"=>5}}
```

注意：定義在`active_support/core_ext/hash/keys.rb`中。


#### `symbolize_keys`和`symbolize_keys!`

方法[`symbolize_keys`][Hash#symbolize_keys]返回一個鍵為接收者鍵的符號化版本的哈希（在可能的情況下）。它通過對鍵發送`to_sym`來實現：

```ruby
{ nil => nil, 1 => 1, "a" => "a" }.symbolize_keys
# => {nil=>nil, 1=>1, :a=>"a"}
```

警告。請注意，在前面的示例中，只有一個鍵被符號化。

在鍵碰撞的情況下，值將是最近插入哈希中的值：

```ruby
{ "a" => 1, a: 2 }.symbolize_keys
# => {:a=>2}
```

這個方法可能很有用，例如可以輕鬆接受符號和字符串作為選項。例如，`ActionText::TagHelper`定義了
```ruby
def rich_text_area_tag(name, value = nil, options = {})
  options = options.symbolize_keys

  options[:input] ||= "trix_input_#{ActionText::TagHelper.id += 1}"
  # ...
end
```

第三行可以安全地訪問`:input`鍵，並允許用戶傳遞`:input`或"input"。

還有一個感嘆號變體[`symbolize_keys!`][Hash#symbolize_keys!]，可以原地將鍵轉換為符號。

此外，還可以使用[`deep_symbolize_keys`][Hash#deep_symbolize_keys]和[`deep_symbolize_keys!`][Hash#deep_symbolize_keys!]來將給定哈希中的所有鍵和所有嵌套在其中的哈希轉換為符號。結果的示例如下：

```ruby
{ nil => nil, 1 => 1, "nested" => { "a" => 3, 5 => 5 } }.deep_symbolize_keys
# => {nil=>nil, 1=>1, nested:{a:3, 5=>5}}
```

注意：定義在`active_support/core_ext/hash/keys.rb`中。


#### `to_options`和`to_options!`

方法[`to_options`][Hash#to_options]和[`to_options!`][Hash#to_options!]是`symbolize_keys`和`symbolize_keys!`的別名，分別。

注意：定義在`active_support/core_ext/hash/keys.rb`中。


#### `assert_valid_keys`

方法[`assert_valid_keys`][Hash#assert_valid_keys]接收任意數量的參數，並檢查接收者是否有任何在該列表之外的鍵。如果有，則引發`ArgumentError`。

```ruby
{ a: 1 }.assert_valid_keys(:a)  # 通過
{ a: 1 }.assert_valid_keys("a") # 引發ArgumentError
```

例如，Active Record在構建關聯時不接受未知選項。它通過`assert_valid_keys`實現了這種控制。

注意：定義在`active_support/core_ext/hash/keys.rb`中。


### 處理值

#### `deep_transform_values`和`deep_transform_values!`

方法[`deep_transform_values`][Hash#deep_transform_values]返回一個新的哈希，其中所有值都通過塊操作進行轉換。這包括根哈希和所有嵌套的哈希和數組的值。

```ruby
hash = { person: { name: 'Rob', age: '28' } }

hash.deep_transform_values { |value| value.to_s.upcase }
# => {person: {name: "ROB", age: "28"}}
```

還有一個感嘆號變體[`deep_transform_values!`][Hash#deep_transform_values!]，它通過使用塊操作來破壞性地轉換所有值。

注意：定義在`active_support/core_ext/hash/deep_transform_values.rb`中。


### 切片

方法[`slice!`][Hash#slice!]用給定的鍵替換哈希，並返回包含刪除的鍵/值對的哈希。

```ruby
hash = { a: 1, b: 2 }
rest = hash.slice!(:a) # => {:b=>2}
hash                   # => {:a=>1}
```

注意：定義在`active_support/core_ext/hash/slice.rb`中。


### 提取

方法[`extract!`][Hash#extract!]刪除並返回與給定鍵匹配的鍵/值對。

```ruby
hash = { a: 1, b: 2 }
rest = hash.extract!(:a) # => {:a=>1}
hash                     # => {:b=>2}
```

方法`extract!`返回與接收者相同的Hash子類。

```ruby
hash = { a: 1, b: 2 }.with_indifferent_access
rest = hash.extract!(:a).class
# => ActiveSupport::HashWithIndifferentAccess
```

注意：定義在`active_support/core_ext/hash/slice.rb`中。


### 不區分大小寫的訪問

方法[`with_indifferent_access`][Hash#with_indifferent_access]將其接收者返回為[`ActiveSupport::HashWithIndifferentAccess`][ActiveSupport::HashWithIndifferentAccess]：

```ruby
{ a: 1 }.with_indifferent_access["a"] # => 1
```

注意：定義在`active_support/core_ext/hash/indifferent_access.rb`中。


`Regexp`的擴展
----------------------

### `multiline?`

方法[`multiline?`][Regexp#multiline?]表示正則表達式是否設置了`/m`標誌，即點是否匹配換行符。

```ruby
%r{.}.multiline?  # => false
%r{.}m.multiline? # => true

Regexp.new('.').multiline?                    # => false
Regexp.new('.', Regexp::MULTILINE).multiline? # => true
```

Rails在一個地方使用這個方法，也是在路由代碼中。在路由要求中，不允許使用多行正則表達式，這個標誌可以方便地強制執行這個限制。

```ruby
def verify_regexp_requirements(requirements)
  # ...
  if requirement.multiline?
    raise ArgumentError, "Regexp multiline option is not allowed in routing requirements: #{requirement.inspect}"
  end
  # ...
end
```
注意：在`active_support/core_ext/regexp.rb`中定义。

`Range`的扩展
---------------------

### `to_fs`

Active Support定义了`Range#to_fs`作为`to_s`的替代方法，它可以理解一个可选的格式参数。截至目前，唯一支持的非默认格式是`:db`：

```ruby
(Date.today..Date.tomorrow).to_fs
# => "2009-10-25..2009-10-26"

(Date.today..Date.tomorrow).to_fs(:db)
# => "BETWEEN '2009-10-25' AND '2009-10-26'"
```

正如示例所示，`：db`格式生成了一个`BETWEEN`的SQL子句。这在Active Record中用于支持条件中的范围值。

注意：在`active_support/core_ext/range/conversions.rb`中定义。

### `===`和`include?`

方法`Range#===`和`Range#include?`用于判断某个值是否在给定范围的两端之间：

```ruby
(2..3).include?(Math::E) # => true
```

Active Support扩展了这些方法，使得参数可以是另一个范围。在这种情况下，我们测试参数范围的两端是否属于接收者本身：

```ruby
(1..10) === (3..7)  # => true
(1..10) === (0..7)  # => false
(1..10) === (3..11) # => false
(1...9) === (3..9)  # => false

(1..10).include?(3..7)  # => true
(1..10).include?(0..7)  # => false
(1..10).include?(3..11) # => false
(1...9).include?(3..9)  # => false
```

注意：在`active_support/core_ext/range/compare_range.rb`中定义。

### `overlap?`

方法[`Range#overlap?`][Range#overlap?]用于判断任意两个给定范围是否有非空交集：

```ruby
(1..10).overlap?(7..11)  # => true
(1..10).overlap?(0..7)   # => true
(1..10).overlap?(11..27) # => false
```

注意：在`active_support/core_ext/range/overlap.rb`中定义。

`Date`的扩展
--------------------

### 计算

注意：以下计算方法在1582年10月存在特殊情况，因为第5到14天根本不存在。为了简洁起见，本指南不会详细说明它们在这些日期周围的行为，但可以肯定的是它们会按照你的期望进行计算。也就是说，`Date.new(1582, 10, 4).tomorrow`返回`Date.new(1582, 10, 15)`等等。请查看Active Support测试套件中的`test/core_ext/date_ext_test.rb`以获取预期的行为。

#### `Date.current`

Active Support定义了[`Date.current`][Date.current]作为当前时区的今天日期。它类似于`Date.today`，但会尊重用户定义的时区。它还定义了[`Date.yesterday`][Date.yesterday]和[`Date.tomorrow`][Date.tomorrow]，以及实例谓词[`past?`][DateAndTime::Calculations#past?]、[`today?`][DateAndTime::Calculations#today?]、[`tomorrow?`][DateAndTime::Calculations#tomorrow?]、[`next_day?`][DateAndTime::Calculations#next_day?]、[`yesterday?`][DateAndTime::Calculations#yesterday?]、[`prev_day?`][DateAndTime::Calculations#prev_day?]、[`future?`][DateAndTime::Calculations#future?]、[`on_weekday?`][DateAndTime::Calculations#on_weekday?]和[`on_weekend?`][DateAndTime::Calculations#on_weekend?]，它们都相对于`Date.current`。

在使用尊重用户时区的方法进行日期比较时，请确保使用`Date.current`而不是`Date.today`。有些情况下，用户时区可能比系统时区更靠未来，而`Date.today`默认使用系统时区。这意味着`Date.today`可能等于`Date.yesterday`。

注意：在`active_support/core_ext/date/calculations.rb`中定义。

#### 命名日期

##### `beginning_of_week`、`end_of_week`

方法[`beginning_of_week`][DateAndTime::Calculations#beginning_of_week]和[`end_of_week`][DateAndTime::Calculations#end_of_week]分别返回一周的开始日期和结束日期。默认情况下，一周从星期一开始，但可以通过传递参数、设置线程本地`Date.beginning_of_week`或[`config.beginning_of_week`][]来更改。

```ruby
d = Date.new(2010, 5, 8)     # => Sat, 08 May 2010
d.beginning_of_week          # => Mon, 03 May 2010
d.beginning_of_week(:sunday) # => Sun, 02 May 2010
d.end_of_week                # => Sun, 09 May 2010
d.end_of_week(:sunday)       # => Sat, 08 May 2010
```

`beginning_of_week`的别名是[`at_beginning_of_week`][DateAndTime::Calculations#at_beginning_of_week]，`end_of_week`的别名是[`at_end_of_week`][DateAndTime::Calculations#at_end_of_week]。

注意：在`active_support/core_ext/date_and_time/calculations.rb`中定义。

##### `monday`、`sunday`

方法[`monday`][DateAndTime::Calculations#monday]和[`sunday`][DateAndTime::Calculations#sunday]分别返回上一个星期一和下一个星期日的日期。
```ruby
date = Date.new(2010, 6, 7)
date.months_ago(3)   # => Mon, 07 Mar 2010
date.months_since(3) # => Thu, 07 Sep 2010
```

If such a day does not exist, the last day of the corresponding month is returned:

```ruby
Date.new(2012, 3, 31).months_ago(1)     # => Thu, 29 Feb 2012
Date.new(2012, 1, 31).months_since(1)   # => Thu, 29 Feb 2012
```

[`last_month`][DateAndTime::Calculations#last_month] is short-hand for `#months_ago(1)`.

NOTE: Defined in `active_support/core_ext/date_and_time/calculations.rb`.


##### `weeks_ago`, `weeks_since`

The methods [`weeks_ago`][DateAndTime::Calculations#weeks_ago] and [`weeks_since`][DateAndTime::Calculations#weeks_since] work analogously for weeks:

```ruby
date = Date.new(2010, 6, 7)
date.weeks_ago(2)   # => Mon, 24 May 2010
date.weeks_since(2) # => Mon, 21 Jun 2010
```

If such a day does not exist, the last day of the corresponding month is returned:

```ruby
Date.new(2012, 3, 31).weeks_ago(4)     # => Sat, 03 Mar 2012
Date.new(2012, 1, 31).weeks_since(4)   # => Sat, 03 Mar 2012
```

[`last_week`][DateAndTime::Calculations#last_week] is short-hand for `#weeks_ago(1)`.

NOTE: Defined in `active_support/core_ext/date_and_time/calculations.rb`.


##### `days_ago`, `days_since`

The methods [`days_ago`][DateAndTime::Calculations#days_ago] and [`days_since`][DateAndTime::Calculations#days_since] work analogously for days:

```ruby
date = Date.new(2010, 6, 7)
date.days_ago(5)   # => Wed, 02 Jun 2010
date.days_since(5) # => Sat, 12 Jun 2010
```

[`yesterday`][DateAndTime::Calculations#yesterday] is short-hand for `#days_ago(1)`, and [`tomorrow`][DateAndTime::Calculations#tomorrow] is short-hand for `#days_since(1)`.

NOTE: Defined in `active_support/core_ext/date_and_time/calculations.rb`.
```ruby
Date.new(2010, 4, 30).months_ago(2)   # => Sun, 28 Feb 2010
Date.new(2010, 4, 30).months_since(2) # => Wed, 30 Jun 2010
```

如果該日期不存在，則返回該月的最後一天：

```ruby
Date.new(2010, 4, 30).months_ago(2)    # => Sun, 28 Feb 2010
Date.new(2009, 12, 31).months_since(2) # => Sun, 28 Feb 2010
```

[`last_month`][DateAndTime::Calculations#last_month] 是 `#months_ago(1)` 的簡寫。

注意：定義在 `active_support/core_ext/date_and_time/calculations.rb`。


##### `weeks_ago`

[`weeks_ago`][DateAndTime::Calculations#weeks_ago] 方法對於週數也是類似的：

```ruby
Date.new(2010, 5, 24).weeks_ago(1)    # => Mon, 17 May 2010
Date.new(2010, 5, 24).weeks_ago(2)    # => Mon, 10 May 2010
```

注意：定義在 `active_support/core_ext/date_and_time/calculations.rb`。


##### `advance`

最通用的跳轉到其他日期的方法是 [`advance`][Date#advance]。該方法接收一個帶有 `:years`、`:months`、`:weeks`、`:days` 鍵的哈希，並根據這些鍵的值返回一個進階的日期：

```ruby
date = Date.new(2010, 6, 6)
date.advance(years: 1, weeks: 2)  # => Mon, 20 Jun 2011
date.advance(months: 2, days: -2) # => Wed, 04 Aug 2010
```

請注意，在上面的示例中，增量可以是負數。

注意：定義在 `active_support/core_ext/date/calculations.rb`。


#### 更改組件

[`change`][Date#change] 方法允許您獲取一個新的日期，該日期與接收器相同，只是年份、月份或日期不同：

```ruby
Date.new(2010, 12, 23).change(year: 2011, month: 11)
# => Wed, 23 Nov 2011
```

如果更改無效，即日期不存在，則會引發 `ArgumentError`：

```ruby
Date.new(2010, 1, 31).change(month: 2)
# => ArgumentError: invalid date
```

注意：定義在 `active_support/core_ext/date/calculations.rb`。


#### 持續時間

可以將 [`Duration`][ActiveSupport::Duration] 對象添加到日期中或從日期中減去：

```ruby
d = Date.current
# => Mon, 09 Aug 2010
d + 1.year
# => Tue, 09 Aug 2011
d - 3.hours
# => Sun, 08 Aug 2010 21:00:00 UTC +00:00
```

它們對應於對 `since` 或 `advance` 的調用。例如，在這裡，我們得到了日曆改革中的正確跳躍：

```ruby
Date.new(1582, 10, 4) + 1.day
# => Fri, 15 Oct 1582
```


#### 時間戳

INFO：如果可能，以下方法返回一個 `Time` 對象，否則返回一個 `DateTime` 對象。如果設置了用戶時區，它們會遵循用戶時區。

##### `beginning_of_day`、`end_of_day`

[`beginning_of_day`][Date#beginning_of_day] 方法返回一天的開始時間戳（00:00:00）：

```ruby
date = Date.new(2010, 6, 7)
date.beginning_of_day # => Mon Jun 07 00:00:00 +0200 2010
```

[`end_of_day`][Date#end_of_day] 方法返回一天的結束時間戳（23:59:59）：

```ruby
date = Date.new(2010, 6, 7)
date.end_of_day # => Mon Jun 07 23:59:59 +0200 2010
```

`beginning_of_day` 的別名是 [`at_beginning_of_day`][Date#at_beginning_of_day]、[`midnight`][Date#midnight]、[`at_midnight`][Date#at_midnight]。

注意：定義在 `active_support/core_ext/date/calculations.rb`。


##### `beginning_of_hour`、`end_of_hour`

[`beginning_of_hour`][DateTime#beginning_of_hour] 方法返回一小時的開始時間戳（hh:00:00）：

```ruby
date = DateTime.new(2010, 6, 7, 19, 55, 25)
date.beginning_of_hour # => Mon Jun 07 19:00:00 +0200 2010
```

[`end_of_hour`][DateTime#end_of_hour] 方法返回一小時的結束時間戳（hh:59:59）：

```ruby
date = DateTime.new(2010, 6, 7, 19, 55, 25)
date.end_of_hour # => Mon Jun 07 19:59:59 +0200 2010
```

`beginning_of_hour` 的別名是 [`at_beginning_of_hour`][DateTime#at_beginning_of_hour]。

注意：定義在 `active_support/core_ext/date_time/calculations.rb`。

##### `beginning_of_minute`、`end_of_minute`

[`beginning_of_minute`][DateTime#beginning_of_minute] 方法返回一分鐘的開始時間戳（hh:mm:00）：
```ruby
date = DateTime.new(2010, 6, 7, 19, 55, 25)
date.beginning_of_minute # => 2010年6月7日星期一19:55:00 +0200

```

[`end_of_minute`][DateTime#end_of_minute]方法返回該分鐘結束的時間戳記（hh:mm:59）：

```ruby
date = DateTime.new(2010, 6, 7, 19, 55, 25)
date.end_of_minute # => 2010年6月7日星期一19:55:59 +0200
```

`beginning_of_minute`別名為[`at_beginning_of_minute`][DateTime#at_beginning_of_minute]。

INFO: `beginning_of_hour`、`end_of_hour`、`beginning_of_minute`和`end_of_minute`方法對`Time`和`DateTime`進行了實現，但對於`Date`則沒有實現，因為在`Date`實例上請求小時或分鐘的開始或結束是沒有意義的。

NOTE: 定義在`active_support/core_ext/date_time/calculations.rb`中。


##### `ago`、`since`

[`ago`][Date#ago]方法接收一個以秒為單位的數字作為參數，並返回從午夜開始計算的指定秒數前的時間戳記：

```ruby
date = Date.current # => 2010年6月11日星期五
date.ago(1)         # => 2010年6月10日星期四23:59:59 EDT -04:00
```

同樣地，[`since`][Date#since]方法向前移動：

```ruby
date = Date.current # => 2010年6月11日星期五
date.since(1)       # => 2010年6月11日星期五00:00:01 EDT -04:00
```

NOTE: 定義在`active_support/core_ext/date/calculations.rb`中。


`DateTime`的擴展
------------------------

警告：`DateTime`不知道夏令時規則，因此在進行夏令時更改時，某些方法可能存在邊界情況。例如，在這樣的一天中，[`seconds_since_midnight`][DateTime#seconds_since_midnight]可能不會返回實際的秒數。

### 計算

`DateTime`類是`Date`的子類，因此通過加載`active_support/core_ext/date/calculations.rb`，您繼承了這些方法及其別名，只是它們始終返回日期時間。

以下方法已重新實現，因此您**不需要**為這些方法加載`active_support/core_ext/date/calculations.rb`：

* [`beginning_of_day`][DateTime#beginning_of_day] / [`midnight`][DateTime#midnight] / [`at_midnight`][DateTime#at_midnight] / [`at_beginning_of_day`][DateTime#at_beginning_of_day]
* [`end_of_day`][DateTime#end_of_day]
* [`ago`][DateTime#ago]
* [`since`][DateTime#since] / [`in`][DateTime#in]

另一方面，[`advance`][DateTime#advance]和[`change`][DateTime#change]也被定義並支持更多選項，下面將對其進行說明。

以下方法僅在`active_support/core_ext/date_time/calculations.rb`中實現，因為它們只在與`DateTime`實例一起使用時才有意義：

* [`beginning_of_hour`][DateTime#beginning_of_hour] / [`at_beginning_of_hour`][DateTime#at_beginning_of_hour]
* [`end_of_hour`][DateTime#end_of_hour]


#### 命名的日期時間

##### `DateTime.current`

Active Support定義了[`DateTime.current`][DateTime.current]，類似於`Time.now.to_datetime`，但它遵循用戶的時區（如果已定義）。實例謂詞[`past?`][DateAndTime::Calculations#past?]和[`future?`][DateAndTime::Calculations#future?]相對於`DateTime.current`定義。

NOTE: 定義在`active_support/core_ext/date_time/calculations.rb`中。


#### 其他擴展

##### `seconds_since_midnight`

[`seconds_since_midnight`][DateTime#seconds_since_midnight]方法返回從午夜開始的秒數：

```ruby
now = DateTime.current     # => 2010年6月7日星期一20:26:36 +0000
now.seconds_since_midnight # => 73596
```

NOTE: 定義在`active_support/core_ext/date_time/calculations.rb`中。


##### `utc`

[`utc`][DateTime#utc]方法以UTC表示方式給出與接收者相同的日期時間。

```ruby
now = DateTime.current # => 2010年6月7日星期一19:27:52 -0400
now.utc                # => 2010年6月7日星期一23:27:52 +0000
```

此方法也別名為[`getutc`][DateTime#getutc]。

NOTE: 定義在`active_support/core_ext/date_time/calculations.rb`中。


##### `utc?`

謂詞[`utc?`][DateTime#utc?]表示接收者是否具有UTC作為其時區：

```ruby
now = DateTime.now # => 2010年6月7日星期一19:30:47 -0400
now.utc?           # => false
now.utc.utc?       # => true
```

NOTE: 定義在`active_support/core_ext/date_time/calculations.rb`中。


##### `advance`

跳轉到另一個日期時間的最通用方法是[`advance`][DateTime#advance]。此方法接收一個帶有鍵`：years`、`：months`、`：weeks`、`：days`、`：hours`、`：minutes`和`：seconds`的哈希，並根據這些鍵指示的時間量返回一個日期時間。

```ruby
d = DateTime.current
# => 週四, 05 八月 2010 11:33:31 +0000
d.advance(years: 1, months: 1, days: 1, hours: 1, minutes: 1, seconds: 1)
# => 週二, 06 九月 2011 12:34:32 +0000
```

此方法首先使用`Date#advance`計算目標日期，傳遞`：years`，`：months`，`：weeks`和`：days`。然後，使用要前進的秒數調整時間，調用[`since`][DateTime#since]。這個順序很重要，在某些邊緣情況下，不同的順序會得到不同的日期時間。`Date#advance`中的示例適用，我們可以擴展它以顯示與時間位相關的順序相關性。

如果我們首先移動日期位（這些位元也有一個相對的處理順序，如前面所述），然後移動時間位，我們可以得到以下計算結果：

```ruby
d = DateTime.new(2010, 2, 28, 23, 59, 59)
# => 週日, 28 二月 2010 23:59:59 +0000
d.advance(months: 1, seconds: 1)
# => 週一, 29 三月 2010 00:00:00 +0000
```

但是如果我們以相反的方式計算它們，結果將不同：

```ruby
d.advance(seconds: 1).advance(months: 1)
# => 週四, 01 四月 2010 00:00:00 +0000
```

警告：由於`DateTime`不支持夏令時，您可能會在不存在的時間點上結束，而沒有任何警告或錯誤告訴您。

注意：定義在`active_support/core_ext/date_time/calculations.rb`中。


#### 更改組件

方法[`change`][DateTime#change]允許您獲得一個新的日期時間，該日期時間與接收器相同，除了給定的選項外，這些選項可能包括`：year`，`：month`，`：day`，`：hour`，`：min`，`：sec`，`：offset`，`：start`：

```ruby
now = DateTime.current
# => 週二, 08 六月 2010 01:56:22 +0000
now.change(year: 2011, offset: Rational(-6, 24))
# => 週三, 08 六月 2011 01:56:22 -0600
```

如果小時為零，則分鐘和秒鐘也為零（除非它們有給定的值）：

```ruby
now.change(hour: 0)
# => 週二, 08 六月 2010 00:00:00 +0000
```

同樣，如果分鐘為零，則秒鐘也為零（除非它有給定的值）：

```ruby
now.change(min: 0)
# => 週二, 08 六月 2010 01:00:00 +0000
```

如果更改無效，此方法不容忍不存在的日期，將引發`ArgumentError`：

```ruby
DateTime.current.change(month: 2, day: 30)
# => ArgumentError: invalid date
```

注意：定義在`active_support/core_ext/date_time/calculations.rb`中。


#### 持續時間

可以將[`Duration`][ActiveSupport::Duration]對象添加到日期時間中，並從日期時間中減去：

```ruby
now = DateTime.current
# => 週一, 09 八月 2010 23:15:17 +0000
now + 1.year
# => 週二, 09 八月 2011 23:15:17 +0000
now - 1.week
# => 週一, 02 八月 2010 23:15:17 +0000
```

它們轉換為對`since`或`advance`的調用。例如，在這裡，我們得到了日曆改革的正確跳躍：

```ruby
DateTime.new(1582, 10, 4, 23) + 1.hour
# => 週五, 15 十月 1582 00:00:00 +0000
```

`Time`的擴展
--------------------

### 計算

它們是類似的。請參閱上面的文檔，並考慮以下差異：

* [`change`][Time#change]接受額外的`：usec`選項。
* `Time`了解夏令時，因此您可以得到正確的夏令時計算，如下所示：

```ruby
Time.zone_default
# => #<ActiveSupport::TimeZone:0x7f73654d4f38 @utc_offset=nil, @name="Madrid", ...>

# 在巴塞羅那，2010/03/28 02:00 +0100 變為 2010/03/28 03:00 +0200，因為夏令時。
t = Time.local(2010, 3, 28, 1, 59, 59)
# => 週日 三月 28 01:59:59 +0100 2010
t.advance(seconds: 1)
# => 週日 三月 28 03:00:00 +0200 2010
```
```
* 如果 [`since`][Time#since] 或 [`ago`][Time#ago] 跳到無法用 `Time` 表示的時間，則會返回一個 `DateTime` 物件。

#### `Time.current`

Active Support 定義 [`Time.current`][Time.current] 為當前時區的今天。這與 `Time.now` 相同，但會尊重用戶定義的時區。它還定義了實例方法 [`past?`][DateAndTime::Calculations#past?]、[`today?`][DateAndTime::Calculations#today?]、[`tomorrow?`][DateAndTime::Calculations#tomorrow?]、[`next_day?`][DateAndTime::Calculations#next_day?]、[`yesterday?`][DateAndTime::Calculations#yesterday?]、[`prev_day?`][DateAndTime::Calculations#prev_day?] 和 [`future?`][DateAndTime::Calculations#future?]，它們都是相對於 `Time.current` 的。

在使用尊重用戶時區的方法進行時間比較時，請確保使用 `Time.current` 而不是 `Time.now`。有些情況下，用戶時區可能比系統時區更靠未來，而 `Time.now` 默認使用系統時區。這意味著 `Time.now.to_date` 可能等於 `Date.yesterday`。

注意：定義在 `active_support/core_ext/time/calculations.rb` 中。

#### `all_day`, `all_week`, `all_month`, `all_quarter` 和 `all_year`

方法 [`all_day`][DateAndTime::Calculations#all_day] 返回表示當前時間整天的範圍。

```ruby
now = Time.current
# => Mon, 09 Aug 2010 23:20:05 UTC +00:00
now.all_day
# => Mon, 09 Aug 2010 00:00:00 UTC +00:00..Mon, 09 Aug 2010 23:59:59 UTC +00:00
```

類似地，[`all_week`][DateAndTime::Calculations#all_week]、[`all_month`][DateAndTime::Calculations#all_month]、[`all_quarter`][DateAndTime::Calculations#all_quarter] 和 [`all_year`][DateAndTime::Calculations#all_year] 都用於生成時間範圍。

```ruby
now = Time.current
# => Mon, 09 Aug 2010 23:20:05 UTC +00:00
now.all_week
# => Mon, 09 Aug 2010 00:00:00 UTC +00:00..Sun, 15 Aug 2010 23:59:59 UTC +00:00
now.all_week(:sunday)
# => Sun, 16 Sep 2012 00:00:00 UTC +00:00..Sat, 22 Sep 2012 23:59:59 UTC +00:00
now.all_month
# => Sat, 01 Aug 2010 00:00:00 UTC +00:00..Tue, 31 Aug 2010 23:59:59 UTC +00:00
now.all_quarter
# => Thu, 01 Jul 2010 00:00:00 UTC +00:00..Thu, 30 Sep 2010 23:59:59 UTC +00:00
now.all_year
# => Fri, 01 Jan 2010 00:00:00 UTC +00:00..Fri, 31 Dec 2010 23:59:59 UTC +00:00
```

注意：定義在 `active_support/core_ext/date_and_time/calculations.rb` 中。

#### `prev_day`, `next_day`

[`prev_day`][Time#prev_day] 和 [`next_day`][Time#next_day] 返回前一天或後一天的時間：

```ruby
t = Time.new(2010, 5, 8) # => 2010-05-08 00:00:00 +0900
t.prev_day               # => 2010-05-07 00:00:00 +0900
t.next_day               # => 2010-05-09 00:00:00 +0900
```

注意：定義在 `active_support/core_ext/time/calculations.rb` 中。

#### `prev_month`, `next_month`

[`prev_month`][Time#prev_month] 和 [`next_month`][Time#next_month] 返回上個月或下個月的同一天的時間：

```ruby
t = Time.new(2010, 5, 8) # => 2010-05-08 00:00:00 +0900
t.prev_month             # => 2010-04-08 00:00:00 +0900
t.next_month             # => 2010-06-08 00:00:00 +0900
```

如果該天不存在，則返回對應月份的最後一天：

```ruby
Time.new(2000, 5, 31).prev_month # => 2000-04-30 00:00:00 +0900
Time.new(2000, 3, 31).prev_month # => 2000-02-29 00:00:00 +0900
Time.new(2000, 5, 31).next_month # => 2000-06-30 00:00:00 +0900
Time.new(2000, 1, 31).next_month # => 2000-02-29 00:00:00 +0900
```

注意：定義在 `active_support/core_ext/time/calculations.rb` 中。

#### `prev_year`, `next_year`

[`prev_year`][Time#prev_year] 和 [`next_year`][Time#next_year] 返回上一年或下一年的同一天/月的時間：

```ruby
t = Time.new(2010, 5, 8) # => 2010-05-08 00:00:00 +0900
t.prev_year              # => 2009-05-08 00:00:00 +0900
t.next_year              # => 2011-05-08 00:00:00 +0900
```

如果日期是閏年的2月29日，則會返回2月28日：

```ruby
t = Time.new(2000, 2, 29) # => 2000-02-29 00:00:00 +0900
t.prev_year               # => 1999-02-28 00:00:00 +0900
t.next_year               # => 2001-02-28 00:00:00 +0900
```
注意：在`active_support/core_ext/time/calculations.rb`中定义。

#### `prev_quarter`，`next_quarter`

[`prev_quarter`][DateAndTime::Calculations#prev_quarter]和[`next_quarter`][DateAndTime::Calculations#next_quarter]返回前一季度或后一季度的同一天的日期：

```ruby
t = Time.local(2010, 5, 8) # => 2010-05-08 00:00:00 +0300
t.prev_quarter             # => 2010-02-08 00:00:00 +0200
t.next_quarter             # => 2010-08-08 00:00:00 +0300
```

如果不存在这样的日期，则返回相应月份的最后一天：

```ruby
Time.local(2000, 7, 31).prev_quarter  # => 2000-04-30 00:00:00 +0300
Time.local(2000, 5, 31).prev_quarter  # => 2000-02-29 00:00:00 +0200
Time.local(2000, 10, 31).prev_quarter # => 2000-07-31 00:00:00 +0300
Time.local(2000, 11, 31).next_quarter # => 2001-03-01 00:00:00 +0200
```

`prev_quarter`的别名是[`last_quarter`][DateAndTime::Calculations#last_quarter]。

注意：在`active_support/core_ext/date_and_time/calculations.rb`中定义。

### 时间构造函数

Active Support定义了[`Time.current`][Time.current]，如果有用户时区定义，则为`Time.zone.now`，否则为`Time.now`：

```ruby
Time.zone_default
# => #<ActiveSupport::TimeZone:0x7f73654d4f38 @utc_offset=nil, @name="Madrid", ...>
Time.current
# => Fri, 06 Aug 2010 17:11:58 CEST +02:00
```

类似于`DateTime`，谓词[`past?`][DateAndTime::Calculations#past?]和[`future?`][DateAndTime::Calculations#future?]是相对于`Time.current`的。

如果要构造的时间超出运行时平台支持的范围，则丢弃微秒，并返回一个`DateTime`对象。

#### 持续时间

可以将[`Duration`][ActiveSupport::Duration]对象添加到时间对象中或从时间对象中减去：

```ruby
now = Time.current
# => Mon, 09 Aug 2010 23:20:05 UTC +00:00
now + 1.year
# => Tue, 09 Aug 2011 23:21:11 UTC +00:00
now - 1.week
# => Mon, 02 Aug 2010 23:21:11 UTC +00:00
```

它们转换为对`since`或`advance`的调用。例如，这里我们得到了正确的日历改革跳跃：

```ruby
Time.utc(1582, 10, 3) + 5.days
# => Mon Oct 18 00:00:00 UTC 1582
```

`File`的扩展
--------------------

### `atomic_write`

使用类方法[`File.atomic_write`][File.atomic_write]可以以防止任何读取器看到半写内容的方式写入文件。

文件名作为参数传递，该方法会产生一个用于写入的文件句柄。一旦块完成，`atomic_write`关闭文件句柄并完成其工作。

例如，Action Pack使用此方法来写入资产缓存文件，如`all.css`：

```ruby
File.atomic_write(joined_asset_path) do |cache|
  cache.write(join_asset_file_contents(asset_paths))
end
```

为了实现这一点，`atomic_write`创建一个临时文件。这是块中实际写入的文件。完成后，临时文件被重命名，这在POSIX系统上是一个原子操作。如果目标文件存在，`atomic_write`会覆盖它并保留所有者和权限。然而，有一些情况下，`atomic_write`无法更改文件的所有权或权限，这个错误被捕获并跳过，相信用户/文件系统确保文件对需要它的进程是可访问的。

注意。由于`atomic_write`执行的chmod操作，如果目标文件设置了ACL，则会重新计算/修改此ACL。

警告。请注意，您不能使用`atomic_write`进行追加操作。

辅助文件是在一个标准的临时文件目录中写入的，但是您可以将自己选择的目录作为第二个参数传递。

注意：在`active_support/core_ext/file/atomic.rb`中定义。

`NameError`的扩展
-------------------------
Active Support 在 `NameError` 中新增了 [`missing_name?`][NameError#missing_name?] 方法，用於測試異常是否是由於傳遞的名稱引起的。

名稱可以是符號或字符串。對於符號，將與裸常數名稱進行比較，對於字符串，將與完全限定的常數名稱進行比較。

提示：符號可以表示完全限定的常數名稱，例如 `:"ActiveRecord::Base"`，因此符號的行為是為了方便而定義的，而不是出於技術上的必要。

例如，當調用 `ArticlesController` 的操作時，Rails 會嘗試樂觀地使用 `ArticlesHelper`。如果幫助模塊不存在，則不會引發異常，因此如果引發了該常數名稱的異常，則應該將其忽略。但是，可能的情況是 `articles_helper.rb` 引發了 `NameError`，因為存在未知的常數。這應該重新引發。方法 `missing_name?` 提供了一種區分這兩種情況的方式：

```ruby
def default_helper_module!
  module_name = name.delete_suffix("Controller")
  module_path = module_name.underscore
  helper module_path
rescue LoadError => e
  raise e unless e.is_missing? "helpers/#{module_path}_helper"
rescue NameError => e
  raise e unless e.missing_name? "#{module_name}Helper"
end
```

注意：定義在 `active_support/core_ext/name_error.rb` 中。


`LoadError` 的擴展
-------------------------

Active Support 在 `LoadError` 中新增了 [`is_missing?`][LoadError#is_missing?] 方法。

給定一個路徑名，`is_missing?` 方法測試異常是否是由於該特定文件引起的（可能除了 ".rb" 擴展名之外）。

例如，當調用 `ArticlesController` 的操作時，Rails 嘗試加載 `articles_helper.rb`，但該文件可能不存在。這沒問題，幫助模塊不是必需的，因此 Rails 會忽略加載錯誤。但是，可能的情況是幫助模塊確實存在，並且反過來需要另一個缺失的庫。在這種情況下，Rails 必須重新引發異常。方法 `is_missing?` 提供了一種區分這兩種情況的方式：

```ruby
def default_helper_module!
  module_name = name.delete_suffix("Controller")
  module_path = module_name.underscore
  helper module_path
rescue LoadError => e
  raise e unless e.is_missing? "helpers/#{module_path}_helper"
rescue NameError => e
  raise e unless e.missing_name? "#{module_name}Helper"
end
```

注意：定義在 `active_support/core_ext/load_error.rb` 中。


Pathname 的擴展
-------------------------

### `existence`

[`existence`][Pathname#existence] 方法如果指定的文件存在則返回接收器，否則返回 `nil`。這對於以下習慣用法很有用：

```ruby
content = Pathname.new("file").existence&.read
```

注意：定義在 `active_support/core_ext/pathname/existence.rb` 中。
[`config.active_support.bare`]: configuring.html#config-active-support-bare
[Object#blank?]: https://api.rubyonrails.org/classes/Object.html#method-i-blank-3F
[Object#present?]: https://api.rubyonrails.org/classes/Object.html#method-i-present-3F
[Object#presence]: https://api.rubyonrails.org/classes/Object.html#method-i-presence
[Object#duplicable?]: https://api.rubyonrails.org/classes/Object.html#method-i-duplicable-3F
[Object#deep_dup]: https://api.rubyonrails.org/classes/Object.html#method-i-deep_dup
[Object#try]: https://api.rubyonrails.org/classes/Object.html#method-i-try
[Object#try!]: https://api.rubyonrails.org/classes/Object.html#method-i-try-21
[Kernel#class_eval]: https://api.rubyonrails.org/classes/Kernel.html#method-i-class_eval
[Object#acts_like?]: https://api.rubyonrails.org/classes/Object.html#method-i-acts_like-3F
[Array#to_param]: https://api.rubyonrails.org/classes/Array.html#method-i-to_param
[Object#to_param]: https://api.rubyonrails.org/classes/Object.html#method-i-to_param
[Hash#to_query]: https://api.rubyonrails.org/classes/Hash.html#method-i-to_query
[Object#to_query]: https://api.rubyonrails.org/classes/Object.html#method-i-to_query
[Object#with_options]: https://api.rubyonrails.org/classes/Object.html#method-i-with_options
[Object#instance_values]: https://api.rubyonrails.org/classes/Object.html#method-i-instance_values
[Object#instance_variable_names]: https://api.rubyonrails.org/classes/Object.html#method-i-instance_variable_names
[Kernel#enable_warnings]: https://api.rubyonrails.org/classes/Kernel.html#method-i-enable_warnings
[Kernel#silence_warnings]: https://api.rubyonrails.org/classes/Kernel.html#method-i-silence_warnings
[Kernel#suppress]: https://api.rubyonrails.org/classes/Kernel.html#method-i-suppress
[Object#in?]: https://api.rubyonrails.org/classes/Object.html#method-i-in-3F
[Module#alias_attribute]: https://api.rubyonrails.org/classes/Module.html#method-i-alias_attribute
[Module#attr_internal]: https://api.rubyonrails.org/classes/Module.html#method-i-attr_internal
[Module#attr_internal_accessor]: https://api.rubyonrails.org/classes/Module.html#method-i-attr_internal_accessor
[Module#attr_internal_reader]: https://api.rubyonrails.org/classes/Module.html#method-i-attr_internal_reader
[Module#attr_internal_writer]: https://api.rubyonrails.org/classes/Module.html#method-i-attr_internal_writer
[Module#mattr_accessor]: https://api.rubyonrails.org/classes/Module.html#method-i-mattr_accessor
[Module#mattr_reader]: https://api.rubyonrails.org/classes/Module.html#method-i-mattr_reader
[Module#mattr_writer]: https://api.rubyonrails.org/classes/Module.html#method-i-mattr_writer
[Module#module_parent]: https://api.rubyonrails.org/classes/Module.html#method-i-module_parent
[Module#module_parent_name]: https://api.rubyonrails.org/classes/Module.html#method-i-module_parent_name
[Module#module_parents]: https://api.rubyonrails.org/classes/Module.html#method-i-module_parents
[Module#anonymous?]: https://api.rubyonrails.org/classes/Module.html#method-i-anonymous-3F
[Module#delegate]: https://api.rubyonrails.org/classes/Module.html#method-i-delegate
[Module#delegate_missing_to]: https://api.rubyonrails.org/classes/Module.html#method-i-delegate_missing_to
[Module#redefine_method]: https://api.rubyonrails.org/classes/Module.html#method-i-redefine_method
[Module#silence_redefinition_of_method]: https://api.rubyonrails.org/classes/Module.html#method-i-silence_redefinition_of_method
[Class#class_attribute]: https://api.rubyonrails.org/classes/Class.html#method-i-class_attribute
[Module#cattr_accessor]: https://api.rubyonrails.org/classes/Module.html#method-i-cattr_accessor
[Module#cattr_reader]: https://api.rubyonrails.org/classes/Module.html#method-i-cattr_reader
[Module#cattr_writer]: https://api.rubyonrails.org/classes/Module.html#method-i-cattr_writer
[Class#subclasses]: https://api.rubyonrails.org/classes/Class.html#method-i-subclasses
[Class#descendants]: https://api.rubyonrails.org/classes/Class.html#method-i-descendants
[`raw`]: https://api.rubyonrails.org/classes/ActionView/Helpers/OutputSafetyHelper.html#method-i-raw
[String#html_safe]: https://api.rubyonrails.org/classes/String.html#method-i-html_safe
[String#remove]: https://api.rubyonrails.org/classes/String.html#method-i-remove
[String#squish]: https://api.rubyonrails.org/classes/String.html#method-i-squish
[String#truncate]: https://api.rubyonrails.org/classes/String.html#method-i-truncate
[String#truncate_bytes]: https://api.rubyonrails.org/classes/String.html#method-i-truncate_bytes
[String#truncate_words]: https://api.rubyonrails.org/classes/String.html#method-i-truncate_words
[String#inquiry]: https://api.rubyonrails.org/classes/String.html#method-i-inquiry
[String#strip_heredoc]: https://api.rubyonrails.org/classes/String.html#method-i-strip_heredoc
[String#indent!]: https://api.rubyonrails.org/classes/String.html#method-i-indent-21
[String#indent]: https://api.rubyonrails.org/classes/String.html#method-i-indent
[String#at]: https://api.rubyonrails.org/classes/String.html#method-i-at
[String#from]: https://api.rubyonrails.org/classes/String.html#method-i-from
[String#to]: https://api.rubyonrails.org/classes/String.html#method-i-to
[String#first]: https://api.rubyonrails.org/classes/String.html#method-i-first
[String#last]: https://api.rubyonrails.org/classes/String.html#method-i-last
[String#pluralize]: https://api.rubyonrails.org/classes/String.html#method-i-pluralize
[String#singularize]: https://api.rubyonrails.org/classes/String.html#method-i-singularize
[String#camelcase]: https://api.rubyonrails.org/classes/String.html#method-i-camelcase
[String#camelize]: https://api.rubyonrails.org/classes/String.html#method-i-camelize
[String#underscore]: https://api.rubyonrails.org/classes/String.html#method-i-underscore
[String#titlecase]: https://api.rubyonrails.org/classes/String.html#method-i-titlecase
[String#titleize]: https://api.rubyonrails.org/classes/String.html#method-i-titleize
[String#dasherize]: https://api.rubyonrails.org/classes/String.html#method-i-dasherize
[String#demodulize]: https://api.rubyonrails.org/classes/String.html#method-i-demodulize
[String#deconstantize]: https://api.rubyonrails.org/classes/String.html#method-i-deconstantize
[String#parameterize]: https://api.rubyonrails.org/classes/String.html#method-i-parameterize
[String#tableize]: https://api.rubyonrails.org/classes/String.html#method-i-tableize
[String#classify]: https://api.rubyonrails.org/classes/String.html#method-i-classify
[String#constantize]: https://api.rubyonrails.org/classes/String.html#method-i-constantize
[String#humanize]: https://api.rubyonrails.org/classes/String.html#method-i-humanize
[String#foreign_key]: https://api.rubyonrails.org/classes/String.html#method-i-foreign_key
[String#upcase_first]: https://api.rubyonrails.org/classes/String.html#method-i-upcase_first
[String#downcase_first]: https://api.rubyonrails.org/classes/String.html#method-i-downcase_first
[String#to_date]: https://api.rubyonrails.org/classes/String.html#method-i-to_date
[String#to_datetime]: https://api.rubyonrails.org/classes/String.html#method-i-to_datetime
[String#to_time]: https://api.rubyonrails.org/classes/String.html#method-i-to_time
[Numeric#bytes]: https://api.rubyonrails.org/classes/Numeric.html#method-i-bytes
[Numeric#exabytes]: https://api.rubyonrails.org/classes/Numeric.html#method-i-exabytes
[Numeric#gigabytes]: https://api.rubyonrails.org/classes/Numeric.html#method-i-gigabytes
[Numeric#kilobytes]: https://api.rubyonrails.org/classes/Numeric.html#method-i-kilobytes
[Numeric#megabytes]: https://api.rubyonrails.org/classes/Numeric.html#method-i-megabytes
[Numeric#petabytes]: https://api.rubyonrails.org/classes/Numeric.html#method-i-petabytes
[Numeric#terabytes]: https://api.rubyonrails.org/classes/Numeric.html#method-i-terabytes
[Duration#ago]: https://api.rubyonrails.org/classes/ActiveSupport/Duration.html#method-i-ago
[Duration#from_now]: https://api.rubyonrails.org/classes/ActiveSupport/Duration.html#method-i-from_now
[Numeric#days]: https://api.rubyonrails.org/classes/Numeric.html#method-i-days
[Numeric#fortnights]: https://api.rubyonrails.org/classes/Numeric.html#method-i-fortnights
[Numeric#hours]: https://api.rubyonrails.org/classes/Numeric.html#method-i-hours
[Numeric#minutes]: https://api.rubyonrails.org/classes/Numeric.html#method-i-minutes
[Numeric#seconds]: https://api.rubyonrails.org/classes/Numeric.html#method-i-seconds
[Numeric#weeks]: https://api.rubyonrails.org/classes/Numeric.html#method-i-weeks
[Integer#multiple_of?]: https://api.rubyonrails.org/classes/Integer.html#method-i-multiple_of-3F
[Integer#ordinal]: https://api.rubyonrails.org/classes/Integer.html#method-i-ordinal
[Integer#ordinalize]: https://api.rubyonrails.org/classes/Integer.html#method-i-ordinalize
[Integer#months]: https://api.rubyonrails.org/classes/Integer.html#method-i-months
[Integer#years]: https://api.rubyonrails.org/classes/Integer.html#method-i-years
[Enumerable#sum]: https://api.rubyonrails.org/classes/Enumerable.html#method-i-sum
[Enumerable#index_by]: https://api.rubyonrails.org/classes/Enumerable.html#method-i-index_by
[Enumerable#index_with]: https://api.rubyonrails.org/classes/Enumerable.html#method-i-index_with
[Enumerable#many?]: https://api.rubyonrails.org/classes/Enumerable.html#method-i-many-3F
[Enumerable#exclude?]: https://api.rubyonrails.org/classes/Enumerable.html#method-i-exclude-3F
[Enumerable#including]: https://api.rubyonrails.org/classes/Enumerable.html#method-i-including
[Enumerable#excluding]: https://api.rubyonrails.org/classes/Enumerable.html#method-i-excluding
[Enumerable#without]: https://api.rubyonrails.org/classes/Enumerable.html#method-i-without
[Enumerable#pluck]: https://api.rubyonrails.org/classes/Enumerable.html#method-i-pluck
[Enumerable#pick]: https://api.rubyonrails.org/classes/Enumerable.html#method-i-pick
[Array#excluding]: https://api.rubyonrails.org/classes/Array.html#method-i-excluding
[Array#fifth]: https://api.rubyonrails.org/classes/Array.html#method-i-fifth
[Array#forty_two]: https://api.rubyonrails.org/classes/Array.html#method-i-forty_two
[Array#fourth]: https://api.rubyonrails.org/classes/Array.html#method-i-fourth
[Array#from]: https://api.rubyonrails.org/classes/Array.html#method-i-from
[Array#including]: https://api.rubyonrails.org/classes/Array.html#method-i-including
[Array#second]: https://api.rubyonrails.org/classes/Array.html#method-i-second
[Array#second_to_last]: https://api.rubyonrails.org/classes/Array.html#method-i-second_to_last
[Array#third]: https://api.rubyonrails.org/classes/Array.html#method-i-third
[Array#third_to_last]: https://api.rubyonrails.org/classes/Array.html#method-i-third_to_last
[Array#to]: https://api.rubyonrails.org/classes/Array.html#method-i-to
[Array#extract!]: https://api.rubyonrails.org/classes/Array.html#method-i-extract-21
[Array#extract_options!]: https://api.rubyonrails.org/classes/Array.html#method-i-extract_options-21
[Array#to_sentence]: https://api.rubyonrails.org/classes/Array.html#method-i-to_sentence
[Array#to_fs]: https://api.rubyonrails.org/classes/Array.html#method-i-to_fs
[Array#to_xml]: https://api.rubyonrails.org/classes/Array.html#method-i-to_xml
[Array.wrap]: https://api.rubyonrails.org/classes/Array.html#method-c-wrap
[Array#deep_dup]: https://api.rubyonrails.org/classes/Array.html#method-i-deep_dup
[Array#in_groups_of]: https://api.rubyonrails.org/classes/Array.html#method-i-in_groups_of
[Array#in_groups]: https://api.rubyonrails.org/classes/Array.html#method-i-in_groups
[Array#split]: https://api.rubyonrails.org/classes/Array.html#method-i-split
[Hash#to_xml]: https://api.rubyonrails.org/classes/Hash.html#method-i-to_xml
[Hash#reverse_merge!]: https://api.rubyonrails.org/classes/Hash.html#method-i-reverse_merge-21
[Hash#reverse_merge]: https://api.rubyonrails.org/classes/Hash.html#method-i-reverse_merge
[Hash#reverse_update]: https://api.rubyonrails.org/classes/Hash.html#method-i-reverse_update
[Hash#deep_merge!]: https://api.rubyonrails.org/classes/Hash.html#method-i-deep_merge-21
[Hash#deep_merge]: https://api.rubyonrails.org/classes/Hash.html#method-i-deep_merge
[Hash#deep_dup]: https://api.rubyonrails.org/classes/Hash.html#method-i-deep_dup
[Hash#except!]: https://api.rubyonrails.org/classes/Hash.html#method-i-except-21
[Hash#except]: https://api.rubyonrails.org/classes/Hash.html#method-i-except
[Hash#deep_stringify_keys!]: https://api.rubyonrails.org/classes/Hash.html#method-i-deep_stringify_keys-21
[Hash#deep_stringify_keys]: https://api.rubyonrails.org/classes/Hash.html#method-i-deep_stringify_keys
[Hash#stringify_keys!]: https://api.rubyonrails.org/classes/Hash.html#method-i-stringify_keys-21
[Hash#stringify_keys]: https://api.rubyonrails.org/classes/Hash.html#method-i-stringify_keys
[Hash#deep_symbolize_keys!]: https://api.rubyonrails.org/classes/Hash.html#method-i-deep_symbolize_keys-21
[Hash#deep_symbolize_keys]: https://api.rubyonrails.org/classes/Hash.html#method-i-deep_symbolize_keys
[Hash#symbolize_keys!]: https://api.rubyonrails.org/classes/Hash.html#method-i-symbolize_keys-21
[Hash#symbolize_keys]: https://api.rubyonrails.org/classes/Hash.html#method-i-symbolize_keys
[Hash#to_options!]: https://api.rubyonrails.org/classes/Hash.html#method-i-to_options-21
[Hash#to_options]: https://api.rubyonrails.org/classes/Hash.html#method-i-to_options
[Hash#assert_valid_keys]: https://api.rubyonrails.org/classes/Hash.html#method-i-assert_valid_keys
[Hash#deep_transform_values!]: https://api.rubyonrails.org/classes/Hash.html#method-i-deep_transform_values-21
[Hash#deep_transform_values]: https://api.rubyonrails.org/classes/Hash.html#method-i-deep_transform_values
[Hash#slice!]: https://api.rubyonrails.org/classes/Hash.html#method-i-slice-21
[Hash#extract!]: https://api.rubyonrails.org/classes/Hash.html#method-i-extract-21
[ActiveSupport::HashWithIndifferentAccess]: https://api.rubyonrails.org/classes/ActiveSupport/HashWithIndifferentAccess.html
[Hash#with_indifferent_access]: https://api.rubyonrails.org/classes/Hash.html#method-i-with_indifferent_access
[Regexp#multiline?]: https://api.rubyonrails.org/classes/Regexp.html#method-i-multiline-3F
[Range#overlap?]: https://api.rubyonrails.org/classes/Range.html#method-i-overlaps-3F
[Date.current]: https://api.rubyonrails.org/classes/Date.html#method-c-current
[Date.tomorrow]: https://api.rubyonrails.org/classes/Date.html#method-c-tomorrow
[Date.yesterday]: https://api.rubyonrails.org/classes/Date.html#method-c-yesterday
[DateAndTime::Calculations#future?]: https://api.rubyonrails.org/classes/DateAndTime/Calculations.html#method-i-future-3F
[DateAndTime::Calculations#on_weekday?]: https://api.rubyonrails.org/classes/DateAndTime/Calculations.html#method-i-on_weekday-3F
[DateAndTime::Calculations#on_weekend?]: https://api.rubyonrails.org/classes/DateAndTime/Calculations.html#method-i-on_weekend-3F
[DateAndTime::Calculations#past?]: https://api.rubyonrails.org/classes/DateAndTime/Calculations.html#method-i-past-3F
[`config.beginning_of_week`]: configuring.html#config-beginning-of-week
[DateAndTime::Calculations#at_beginning_of_week]: https://api.rubyonrails.org/classes/DateAndTime/Calculations.html#method-i-at_beginning_of_week
[DateAndTime::Calculations#at_end_of_week]: https://api.rubyonrails.org/classes/DateAndTime/Calculations.html#method-i-at_end_of_week
[DateAndTime::Calculations#beginning_of_week]: https://api.rubyonrails.org/classes/DateAndTime/Calculations.html#method-i-beginning_of_week
[DateAndTime::Calculations#end_of_week]: https://api.rubyonrails.org/classes/DateAndTime/Calculations.html#method-i-end_of_week
[DateAndTime::Calculations#monday]: https://api.rubyonrails.org/classes/DateAndTime/Calculations.html#method-i-monday
[DateAndTime::Calculations#sunday]: https://api.rubyonrails.org/classes/DateAndTime/Calculations.html#method-i-sunday
[Date.beginning_of_week]: https://api.rubyonrails.org/classes/Date.html#method-c-beginning_of_week
[DateAndTime::Calculations#last_week]: https://api.rubyonrails.org/classes/DateAndTime/Calculations.html#method-i-last_week
[DateAndTime::Calculations#next_week]: https://api.rubyonrails.org/classes/DateAndTime/Calculations.html#method-i-next_week
[DateAndTime::Calculations#prev_week]: https://api.rubyonrails.org/classes/DateAndTime/Calculations.html#method-i-prev_week
[DateAndTime::Calculations#at_beginning_of_month]: https://api.rubyonrails.org/classes/DateAndTime/Calculations.html#method-i-at_beginning_of_month
[DateAndTime::Calculations#at_end_of_month]: https://api.rubyonrails.org/classes/DateAndTime/Calculations.html#method-i-at_end_of_month
[DateAndTime::Calculations#beginning_of_month]: https://api.rubyonrails.org/classes/DateAndTime/Calculations.html#method-i-beginning_of_month
[DateAndTime::Calculations#end_of_month]: https://api.rubyonrails.org/classes/DateAndTime/Calculations.html#method-i-end_of_month
[DateAndTime::Calculations#quarter]: https://api.rubyonrails.org/classes/DateAndTime/Calculations.html#method-i-quarter
[DateAndTime::Calculations#at_beginning_of_quarter]: https://api.rubyonrails.org/classes/DateAndTime/Calculations.html#method-i-at_beginning_of_quarter
[DateAndTime::Calculations#at_end_of_quarter]: https://api.rubyonrails.org/classes/DateAndTime/Calculations.html#method-i-at_end_of_quarter
[DateAndTime::Calculations#beginning_of_quarter]: https://api.rubyonrails.org/classes/DateAndTime/Calculations.html#method-i-beginning_of_quarter
[DateAndTime::Calculations#end_of_quarter]: https://api.rubyonrails.org/classes/DateAndTime/Calculations.html#method-i-end_of_quarter
[DateAndTime::Calculations#at_beginning_of_year]: https://api.rubyonrails.org/classes/DateAndTime/Calculations.html#method-i-at_beginning_of_year
[DateAndTime::Calculations#at_end_of_year]: https://api.rubyonrails.org/classes/DateAndTime/Calculations.html#method-i-at_end_of_year
[DateAndTime::Calculations#beginning_of_year]: https://api.rubyonrails.org/classes/DateAndTime/Calculations.html#method-i-beginning_of_year
[DateAndTime::Calculations#end_of_year]: https://api.rubyonrails.org/classes/DateAndTime/Calculations.html#method-i-end_of_year
[DateAndTime::Calculations#last_year]: https://api.rubyonrails.org/classes/DateAndTime/Calculations.html#method-i-last_year
[DateAndTime::Calculations#years_ago]: https://api.rubyonrails.org/classes/DateAndTime/Calculations.html#method-i-years_ago
[DateAndTime::Calculations#years_since]: https://api.rubyonrails.org/classes/DateAndTime/Calculations.html#method-i-years_since
[DateAndTime::Calculations#last_month]: https://api.rubyonrails.org/classes/DateAndTime/Calculations.html#method-i-last_month
[DateAndTime::Calculations#months_ago]: https://api.rubyonrails.org/classes/DateAndTime/Calculations.html#method-i-months_ago
[DateAndTime::Calculations#months_since]: https://api.rubyonrails.org/classes/DateAndTime/Calculations.html#method-i-months_since
[DateAndTime::Calculations#weeks_ago]: https://api.rubyonrails.org/classes/DateAndTime/Calculations.html#method-i-weeks_ago
[Date#advance]: https://api.rubyonrails.org/classes/Date.html#method-i-advance
[Date#change]: https://api.rubyonrails.org/classes/Date.html#method-i-change
[ActiveSupport::Duration]: https://api.rubyonrails.org/classes/ActiveSupport/Duration.html
[Date#at_beginning_of_day]: https://api.rubyonrails.org/classes/Date.html#method-i-at_beginning_of_day
[Date#at_midnight]: https://api.rubyonrails.org/classes/Date.html#method-i-at_midnight
[Date#beginning_of_day]: https://api.rubyonrails.org/classes/Date.html#method-i-beginning_of_day
[Date#end_of_day]: https://api.rubyonrails.org/classes/Date.html#method-i-end_of_day
[Date#midnight]: https://api.rubyonrails.org/classes/Date.html#method-i-midnight
[DateTime#at_beginning_of_minute]: https://api.rubyonrails.org/classes/DateTime.html#method-i-at_beginning_of_minute
[DateTime#beginning_of_minute]: https://api.rubyonrails.org/classes/DateTime.html#method-i-beginning_of_minute
[DateTime#end_of_minute]: https://api.rubyonrails.org/classes/DateTime.html#method-i-end_of_minute
[Date#ago]: https://api.rubyonrails.org/classes/Date.html#method-i-ago
[Date#since]: https://api.rubyonrails.org/classes/Date.html#method-i-since
[DateTime#ago]: https://api.rubyonrails.org/classes/DateTime.html#method-i-ago
[DateTime#at_beginning_of_day]: https://api.rubyonrails.org/classes/DateTime.html#method-i-at_beginning_of_day
[DateTime#at_beginning_of_hour]: https://api.rubyonrails.org/classes/DateTime.html#method-i-at_beginning_of_hour
[DateTime#at_midnight]: https://api.rubyonrails.org/classes/DateTime.html#method-i-at_midnight
[DateTime#beginning_of_day]: https://api.rubyonrails.org/classes/DateTime.html#method-i-beginning_of_day
[DateTime#beginning_of_hour]: https://api.rubyonrails.org/classes/DateTime.html#method-i-beginning_of_hour
[DateTime#end_of_day]: https://api.rubyonrails.org/classes/DateTime.html#method-i-end_of_day
[DateTime#end_of_hour]: https://api.rubyonrails.org/classes/DateTime.html#method-i-end_of_hour
[DateTime#in]: https://api.rubyonrails.org/classes/DateTime.html#method-i-in
[DateTime#midnight]: https://api.rubyonrails.org/classes/DateTime.html#method-i-midnight
[DateTime.current]: https://api.rubyonrails.org/classes/DateTime.html#method-c-current
[DateTime#seconds_since_midnight]: https://api.rubyonrails.org/classes/DateTime.html#method-i-seconds_since_midnight
[DateTime#getutc]: https://api.rubyonrails.org/classes/DateTime.html#method-i-getutc
[DateTime#utc]: https://api.rubyonrails.org/classes/DateTime.html#method-i-utc
[DateTime#utc?]: https://api.rubyonrails.org/classes/DateTime.html#method-i-utc-3F
[DateTime#advance]: https://api.rubyonrails.org/classes/DateTime.html#method-i-advance
[DateTime#since]: https://api.rubyonrails.org/classes/DateTime.html#method-i-since
[DateTime#change]: https://api.rubyonrails.org/classes/DateTime.html#method-i-change
[Time#ago]: https://api.rubyonrails.org/classes/Time.html#method-i-ago
[Time#change]: https://api.rubyonrails.org/classes/Time.html#method-i-change
[Time#since]: https://api.rubyonrails.org/classes/Time.html#method-i-since
[DateAndTime::Calculations#next_day?]: https://api.rubyonrails.org/classes/DateAndTime/Calculations.html#method-i-next_day-3F
[DateAndTime::Calculations#prev_day?]: https://api.rubyonrails.org/classes/DateAndTime/Calculations.html#method-i-prev_day-3F
[DateAndTime::Calculations#today?]: https://api.rubyonrails.org/classes/DateAndTime/Calculations.html#method-i-today-3F
[DateAndTime::Calculations#tomorrow?]: https://api.rubyonrails.org/classes/DateAndTime/Calculations.html#method-i-tomorrow-3F
[DateAndTime::Calculations#yesterday?]: https://api.rubyonrails.org/classes/DateAndTime/Calculations.html#method-i-yesterday-3F
[DateAndTime::Calculations#all_day]: https://api.rubyonrails.org/classes/DateAndTime/Calculations.html#method-i-all_day
[DateAndTime::Calculations#all_month]: https://api.rubyonrails.org/classes/DateAndTime/Calculations.html#method-i-all_month
[DateAndTime::Calculations#all_quarter]: https://api.rubyonrails.org/classes/DateAndTime/Calculations.html#method-i-all_quarter
[DateAndTime::Calculations#all_week]: https://api.rubyonrails.org/classes/DateAndTime/Calculations.html#method-i-all_week
[DateAndTime::Calculations#all_year]: https://api.rubyonrails.org/classes/DateAndTime/Calculations.html#method-i-all_year
[Time.current]: https://api.rubyonrails.org/classes/Time.html#method-c-current
[Time#next_day]: https://api.rubyonrails.org/classes/Time.html#method-i-next_day
[Time#prev_day]: https://api.rubyonrails.org/classes/Time.html#method-i-prev_day
[Time#next_month]: https://api.rubyonrails.org/classes/Time.html#method-i-next_month
[Time#prev_month]: https://api.rubyonrails.org/classes/Time.html#method-i-prev_month
[Time#next_year]: https://api.rubyonrails.org/classes/Time.html#method-i-next_year
[Time#prev_year]: https://api.rubyonrails.org/classes/Time.html#method-i-prev_year
[DateAndTime::Calculations#last_quarter]: https://api.rubyonrails.org/classes/DateAndTime/Calculations.html#method-i-last_quarter
[DateAndTime::Calculations#next_quarter]: https://api.rubyonrails.org/classes/DateAndTime/Calculations.html#method-i-next_quarter
[DateAndTime::Calculations#prev_quarter]: https://api.rubyonrails.org/classes/DateAndTime/Calculations.html#method-i-prev_quarter
[File.atomic_write]: https://api.rubyonrails.org/classes/File.html#method-c-atomic_write
[NameError#missing_name?]: https://api.rubyonrails.org/classes/NameError.html#method-i-missing_name-3F
[LoadError#is_missing?]: https://api.rubyonrails.org/classes/LoadError.html#method-i-is_missing-3F
[Pathname#existence]: https://api.rubyonrails.org/classes/Pathname.html#method-i-existence
