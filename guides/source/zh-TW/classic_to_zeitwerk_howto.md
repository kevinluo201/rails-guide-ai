**DO NOT READ THIS FILE ON GITHUB, GUIDES ARE PUBLISHED ON https://guides.rubyonrails.org.**, original file md5: 9c6201fd526077579ef792e0c4e2150d
Classic to Zeitwerk HOWTO
=========================

本指南記錄了如何將Rails應用程序從“classic”模式遷移到“zeitwerk”模式。

閱讀本指南後，您將了解：

* 什麼是“classic”和“zeitwerk”模式
* 為什麼要從“classic”切換到“zeitwerk”
* 如何激活“zeitwerk”模式
* 如何驗證應用程序是否在“zeitwerk”模式下運行
* 如何驗證項目在命令行中正常加載
* 如何驗證項目在測試套件中正常加載
* 如何處理可能的邊緣情況
* 您可以利用的Zeitwerk中的新功能

--------------------------------------------------------------------------------

什麼是“classic”和“zeitwerk”模式？
--------------------------------------------------------

從一開始到Rails 5，Rails使用了Active Support中實現的自動加載器。這個自動加載器被稱為“classic”，並且在Rails 6.x中仍然可用。Rails 7不再包含此自動加載器。

從Rails 6開始，Rails提供了一種新的並且更好的自動加載方式，它委託給[Zeitwerk](https://github.com/fxn/zeitwerk) gem。這就是“zeitwerk”模式。默認情況下，運行6.0和6.1框架默認值的應用程序在“zeitwerk”模式下運行，並且這是Rails 7中唯一可用的模式。


為什麼要從“classic”切換到“zeitwerk”？
----------------------------------------

“classic”自動加載器非常有用，但是在某些情況下，它存在一些[問題](https://guides.rubyonrails.org/v6.1/autoloading_and_reloading_constants_classic_mode.html#common-gotchas)，這使得自動加載有點棘手和令人困惑。Zeitwerk就是為了解決這個問題而開發的，還有其他[動機](https://github.com/fxn/zeitwerk#motivation)。

升級到Rails 6.x時，強烈建議切換到“zeitwerk”模式，因為它是一個更好的自動加載器，“classic”模式已被棄用。

Rails 7結束了過渡期，不再包含“classic”模式。

我很害怕
-----------

不用擔心 :).

Zeitwerk的設計目標是盡可能與classic自動加載器兼容。如果您的應用程序今天可以正確自動加載，那麼切換應該很容易。許多項目，無論大小，都報告了非常順利的切換。

本指南將幫助您放心地更改自動加載器。

如果出現您不知道如何解決的情況，請隨時在[rails/rails](https://github.com/rails/rails/issues/new)中提出問題並標記[@fxn](https://github.com/fxn)。


如何激活“zeitwerk”模式
-------------------------------

### 運行Rails 5.x或更低版本的應用程序

在運行6.0之前的Rails版本的應用程序中，無法使用“zeitwerk”模式。您需要至少使用Rails 6.0。

### 運行Rails 6.x的應用程序

在運行Rails 6.x的應用程序中，有兩種情況。

如果應用程序正在加載Rails 6.0或6.1的框架默認值並且正在運行在“classic”模式下，則必須手動退出。您需要類似於以下內容：

```ruby
# config/application.rb
config.load_defaults 6.0
config.autoloader = :classic # 刪除此行
```

如上所述，只需刪除此覆蓋，默認情況下是“zeitwerk”模式。

另一方面，如果應用程序正在加載舊的框架默認值，則需要明確啟用“zeitwerk”模式：

```ruby
# config/application.rb
config.load_defaults 5.2
config.autoloader = :zeitwerk
```

### 運行Rails 7的應用程序

在Rails 7中，只有“zeitwerk”模式，您無需做任何操作即可啟用它。

實際上，在Rails 7中，setter `config.autoloader=` 甚至不存在。如果`config/application.rb`使用它，請刪除該行。


如何驗證應用程序是否在“zeitwerk”模式下運行？
------------------------------------------------------

要驗證應用程序是否在“zeitwerk”模式下運行，執行以下命令：

```
bin/rails runner 'p Rails.autoloaders.zeitwerk_enabled?'
```

如果打印出`true`，則啟用了“zeitwerk”模式。


我的應用程序是否符合Zeitwerk的慣例？
-----------------------------------------------------

### config.eager_load_paths

符合性測試僅適用於急於加載的文件。因此，為了驗證Zeitwerk的符合性，建議將所有自動加載路徑添加到急於加載的路徑中。

默認情況下已經是這樣，但是如果項目配置了自定義的自動加載路徑，就像這樣：

```ruby
config.autoload_paths << "#{Rails.root}/extras"
```

這些不會被急於加載，也不會被驗證。將它們添加到急於加載的路徑很容易：

```ruby
config.autoload_paths << "#{Rails.root}/extras"
config.eager_load_paths << "#{Rails.root}/extras"
```

### zeitwerk:check

一旦啟用了“zeitwerk”模式並且仔細檢查了急於加載的路徑配置，請運行：

```
bin/rails zeitwerk:check
```

成功的檢查結果如下：

```
% bin/rails zeitwerk:check
Hold on, I am eager loading the application.
All is good!
```

根據應用程序配置，可能會有其他輸出，但是最後的“All is good!”是您要尋找的。
如果在前一節中解釋的雙重檢查確定實際上需要在急於加載路徑之外添加一些自定義自動加載路徑，任務將檢測並警告您。但是，如果測試套件成功加載這些文件，那就沒問題了。

現在，如果有任何一個文件沒有定義預期的常量，任務將告訴您。它這樣做是一次一個文件，因為如果它繼續進行，加載一個文件失敗可能會導致與我們要運行的檢查無關的其他失敗，並且錯誤報告將會令人困惑。

如果報告了一個常量，請修復該特定常量，然後再次運行任務。重複此步驟，直到獲得“一切正常！”。

以以下為例：

```
% bin/rails zeitwerk:check
請稍等，我正在急於加載應用程序。
預期文件 app/models/vat.rb 定義常量 Vat
```

VAT 是一種歐洲稅收。文件 `app/models/vat.rb` 定義了 `VAT`，但自動加載程序期望 `Vat`，為什麼？

### 首字母縮略詞

這是您可能遇到的最常見的差異，與首字母縮略詞有關。讓我們了解為什麼會出現該錯誤消息。

傳統的自動加載程序能夠自動加載 `VAT`，因為它的輸入是缺少的常量名 `VAT`，對其調用 `underscore`，得到 `vat`，然後尋找名為 `vat.rb` 的文件。這樣可以正常工作。

新的自動加載程序的輸入是文件系統。給定文件 `vat.rb`，Zeitwerk 對 `vat` 調用 `camelize`，得到 `Vat`，並期望該文件定義常量 `Vat`。這就是錯誤消息的含義。

修復這個問題很容易，您只需要告訴 inflector 這個縮略詞：

```ruby
# config/initializers/inflections.rb
ActiveSupport::Inflector.inflections(:en) do |inflect|
  inflect.acronym "VAT"
end
```

這樣做會全局影響 Active Support 的 inflector。這可能沒問題，但如果您希望，您也可以將覆蓋傳遞給自動加載程序使用的 inflector：

```ruby
# config/initializers/zeitwerk.rb
Rails.autoloaders.main.inflector.inflect("vat" => "VAT")
```

使用此選項，您可以更好地控制，因為只有名為 `vat.rb` 的文件或名為 `vat` 的目錄才會被視為 `VAT`。名為 `vat_rules.rb` 的文件不受影響，可以正常定義 `VatRules`。如果項目存在這種命名不一致，這可能很方便。

有了這個設置，檢查通過了！

```
% bin/rails zeitwerk:check
請稍等，我正在急於加載應用程序。
一切正常！
```

一旦一切正常，建議在測試套件中繼續驗證項目。[_在測試套件中檢查 Zeitwerk 遵從性_](#check-zeitwerk-compliance-in-the-test-suite) 部分解釋了如何執行此操作。

### 關注點

您可以從具有 `concerns` 子目錄的標準結構中自動加載和急於加載，例如：

```
app/models
app/models/concerns
```

默認情況下，`app/models/concerns` 屬於自動加載路徑，因此它被認為是根目錄。因此，默認情況下，`app/models/concerns/foo.rb` 應該定義 `Foo`，而不是 `Concerns::Foo`。

如果您的應用程序使用 `Concerns` 作為命名空間，有兩個選擇：

1. 從這些類和模塊中刪除 `Concerns` 命名空間並更新客戶端代碼。
2. 通過從自動加載路徑中刪除 `app/models/concerns` 來保持原樣：

  ```ruby
  # config/initializers/zeitwerk.rb
  ActiveSupport::Dependencies.
    autoload_paths.
    delete("#{Rails.root}/app/models/concerns")
  ```

### 在自動加載路徑中包含 `app`

一些項目希望 `app/api/base.rb` 定義 `API::Base`，並將 `app` 添加到自動加載路徑以實現此目的。

由於 Rails 自動將 `app` 的所有子目錄（有幾個例外）添加到自動加載路徑中，我們又有了另一種情況，類似於 `app/models/concerns` 的情況。然而，這種設置不再起作用。

但是，您可以保持該結構，只需在初始化程序中從自動加載路徑中刪除 `app/api`：

```ruby
# config/initializers/zeitwerk.rb
ActiveSupport::Dependencies.
  autoload_paths.
  delete("#{Rails.root}/app/api")
```

請注意，不要自動加載/急於加載沒有文件的子目錄。例如，如果應用程序具有用於 [ActiveAdmin](https://activeadmin.info/) 的資源的 `app/admin`，您需要忽略它們。對於 `assets` 和其他類似的目錄也是如此：

```ruby
# config/initializers/zeitwerk.rb
Rails.autoloaders.main.ignore(
  "app/admin",
  "app/assets",
  "app/javascripts",
  "app/views"
)
```

如果沒有進行這樣的配置，應用程序將急於加載這些目錄。它會因為這些文件沒有定義常量而出錯，並且會意外定義一個 `Views` 模塊，例如。

正如您所見，將 `app` 包含在自動加載路徑中在技術上是可行的，但有點棘手。

### 自動加載的常量和顯式命名空間

如果命名空間在文件中定義，就像這裡的 `Hotel` 一樣：
```
app/models/hotel.rb         # 定義了 Hotel。
app/models/hotel/pricing.rb # 定義了 Hotel::Pricing。
```

必須使用 `class` 或 `module` 關鍵字設置 `Hotel` 常數。例如：

```ruby
class Hotel
end
```

是正確的。

以下的替代方式：

```ruby
Hotel = Class.new
```

或

```ruby
Hotel = Struct.new
```

將無法正常工作，子對象如 `Hotel::Pricing` 將無法找到。

這個限制只適用於明確的命名空間。未定義命名空間的類和模塊可以使用這些習慣用法定義。

### 一個文件，一個常數（在相同的頂層）

在 `classic` 模式下，你可以在相同的頂層定義多個常數並且它們都會被重新加載。例如，給定以下代碼：

```ruby
# app/models/foo.rb

class Foo
end

class Bar
end
```

雖然 `Bar` 無法自動加載，但自動加載 `Foo` 會標記 `Bar` 為已自動加載。

但在 `zeitwerk` 模式下，你需要將 `Bar` 移到它自己的文件 `bar.rb` 中。一個文件，一個頂層常數。

這只影響與上面示例中相同頂層的常數。內部類和模塊不受影響。例如，考慮以下代碼：

```ruby
# app/models/foo.rb

class Foo
  class InnerClass
  end
end
```

如果應用程序重新加載 `Foo`，它也會重新加載 `Foo::InnerClass`。

### `config.autoload_paths` 中的通配符

請注意，配置中使用通配符的情況，例如：

```ruby
config.autoload_paths += Dir["#{config.root}/extras/**/"]
```

`config.autoload_paths` 的每個元素都應該表示頂層命名空間（`Object`）。這樣是無法正常工作的。

要修復這個問題，只需刪除通配符：

```ruby
config.autoload_paths << "#{config.root}/extras"
```

### 來自引擎的類和模塊的裝飾

如果你的應用程序裝飾了來自引擎的類或模塊，很可能在某個地方做了類似以下的事情：

```ruby
config.to_prepare do
  Dir.glob("#{Rails.root}/app/overrides/**/*_override.rb").sort.each do |override|
    require_dependency override
  end
end
```

這需要進行更新：你需要告訴 `main` 自動加載器忽略覆蓋的目錄，並且需要使用 `load` 加載它們。像這樣：

```ruby
overrides = "#{Rails.root}/app/overrides"
Rails.autoloaders.main.ignore(overrides)
config.to_prepare do
  Dir.glob("#{overrides}/**/*_override.rb").sort.each do |override|
    load override
  end
end
```

### `before_remove_const`

Rails 3.1 添加了對 `before_remove_const` 的支持，如果一個類或模塊響應了這個方法並且將要重新加載，則會調用此回調。這個回調一直沒有被記錄在官方文檔中，並且很少有代碼使用它。

但是，如果你的代碼使用了它，你可以將以下代碼：

```ruby
class Country < ActiveRecord::Base
  def self.before_remove_const
    expire_redis_cache
  end
end
```

改寫為：

```ruby
# config/initializers/country.rb
if Rails.application.config.reloading_enabled?
  Rails.autoloaders.main.on_unload("Country") do |klass, _abspath|
    klass.expire_redis_cache
  end
end
```

### Spring 和 `test` 環境

如果有更改，Spring 會重新加載應用程序代碼。在 `test` 環境中，你需要啟用重新加載才能正常工作：

```ruby
# config/environments/test.rb
config.cache_classes = false
```

或者，從 Rails 7.1 開始：

```ruby
# config/environments/test.rb
config.enable_reloading = true
```

否則，你會得到以下錯誤：

```
reloading is disabled because config.cache_classes is true
```

或

```
reloading is disabled because config.enable_reloading is false
```

這不會對性能產生影響。

### Bootsnap

請確保至少依賴於 Bootsnap 1.4.4。


在測試套件中檢查 Zeitwerk 符合性
--------------------------------

`zeitwerk:check` 任務在遷移時非常方便。一旦項目符合要求，建議自動化進行此檢查。為了實現這一點，只需要急切加載應用程序，這正是 `zeitwerk:check` 做的。

### 持續集成

如果項目有持續集成，建議在測試套件運行時急切加載應用程序。如果由於某種原因無法急切加載應用程序，你希望在持續集成中得知，而不是在生產環境中，對吧？

持續集成通常會設置一些環境變量來指示測試套件正在運行。例如，可以是 `CI`：

```ruby
# config/environments/test.rb
config.eager_load = ENV["CI"].present?
```

從 Rails 7 開始，新生成的應用程序默認配置為這樣。

### 純測試套件

如果項目沒有持續集成，你仍然可以通過調用 `Rails.application.eager_load!` 在測試套件中急切加載：

#### Minitest

```ruby
require "test_helper"

class ZeitwerkComplianceTest < ActiveSupport::TestCase
  test "eager loads all files without errors" do
    assert_nothing_raised { Rails.application.eager_load! }
  end
end
```

#### RSpec

```ruby
require "rails_helper"

RSpec.describe "Zeitwerk compliance" do
  it "eager loads all files without errors" do
    expect { Rails.application.eager_load! }.not_to raise_error
  end
end
```

刪除所有 `require` 調用
----------------------

根據我的經驗，項目通常不會這樣做。但我見過幾個項目這樣做，也聽說過其他一些項目這樣做。
在Rails應用程序中，您專門使用`require`從`lib`或第三方（如gem依賴項或標準庫）加載代碼。**絕不要使用`require`加載可自動加載的應用程序代碼**。在`classic`模式下，請參閱[此處](https://guides.rubyonrails.org/v6.1/autoloading_and_reloading_constants_classic_mode.html#autoloading-and-require)瞭解為什麼這樣做是一個壞主意。

```ruby
require "nokogiri" # 正確
require "net/http" # 正確
require "user"     # 錯誤，刪除此行（假設是app/models/user.rb）
```

請刪除所有這類`require`調用。

您可以利用的新功能
---------------------

### 刪除`require_dependency`調用

使用Zeitwerk已經消除了所有已知的`require_dependency`用例。您應該在項目中使用grep命令並刪除它們。

如果您的應用程序使用單表繼承，請參閱自動加載和重新加載常量（Zeitwerk模式）指南中的[單表繼承部分](autoloading_and_reloading_constants.html#single-table-inheritance)。

### 現在可以在類和模塊定義中使用限定名

您現在可以在類和模塊定義中穩健地使用常量路徑：

```ruby
# 現在，此類主體中的自動加載與Ruby語義相匹配。
class Admin::UsersController < ApplicationController
  # ...
end
```

需要注意的一點是，根據執行順序，classic自動加載器有時可以在以下代碼中自動加載`Foo::Wadus`：

```ruby
class Foo::Bar
  Wadus
end
```

這不符合Ruby語義，因為`Foo`不在嵌套中，並且在`zeitwerk`模式下根本不起作用。如果您發現這樣的邊緣情況，您可以使用限定名`Foo::Wadus`：

```ruby
class Foo::Bar
  Foo::Wadus
end
```

或者將`Foo`添加到嵌套中：

```ruby
module Foo
  class Bar
    Wadus
  end
end
```

### 無處不在的線程安全性

在`classic`模式下，常量自動加載不是線程安全的，儘管Rails已經放置了鎖定機制，例如使Web請求線程安全。

在`zeitwerk`模式下，常量自動加載是線程安全的。例如，現在您可以在由`runner`命令執行的多線程腳本中自動加載。

### 急切加載和自動加載一致

在`classic`模式下，如果`app/models/foo.rb`定義了`Bar`，您將無法自動加載該文件，但急切加載將正常工作，因為它盲目地遞歸加載文件。這可能會導致錯誤，如果您首先測試急切加載，然後在自動加載時執行可能會失敗。

在`zeitwerk`模式下，這兩種加載模式是一致的，它們在相同的文件中失敗和出錯。
