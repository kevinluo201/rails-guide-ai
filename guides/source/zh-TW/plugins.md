**DO NOT READ THIS FILE ON GITHUB, GUIDES ARE PUBLISHED ON https://guides.rubyonrails.org.**, original file md5: b550120024fb17dc176480922543264e
創建Rails插件的基礎知識
=======================

Rails插件可以是核心框架的擴展或修改。插件提供以下功能：

* 讓開發人員分享最新的想法，而不會損壞穩定的代碼庫。
* 分段架構，使得可以單獨修復或更新代碼單元。
* 為核心開發人員提供一個出口，使他們不必包含每個新功能。

閱讀完本指南後，您將了解：

* 如何從頭開始創建插件。
* 如何編寫和運行插件的測試。

本指南描述了如何構建一個測試驅動的插件，該插件將：

* 擴展核心Ruby類，如Hash和String。
* 在`ApplicationRecord`中添加方法，以傳統的`acts_as`插件方式。
* 提供有關在插件中放置生成器的信息。

為了本指南的目的，假設您是一位熱衷的觀鳥者。
您最喜歡的鳥是Yaffle，您想創建一個插件，讓其他開發人員分享Yaffle的優點。

--------------------------------------------------------------------------------

設置
---

目前，Rails插件是作為gem構建的，即_gemified plugins_。如果需要，可以使用RubyGems和Bundler在不同的Rails應用程序之間共享它們。

### 生成一個gem化的插件

Rails提供了一個`rails plugin new`命令，用於創建一個骨架，以開發任何類型的Rails擴展，並能夠使用虛擬的Rails應用程序運行集成測試。使用以下命令創建插件：

```bash
$ rails plugin new yaffle
```

通過請求幫助來查看用法和選項：

```bash
$ rails plugin new --help
```

測試新生成的插件
----------------

切換到包含插件的目錄，編輯`yaffle.gemspec`文件，替換任何具有`TODO`值的行：

```ruby
spec.homepage    = "http://example.com"
spec.summary     = "Summary of Yaffle."
spec.description = "Description of Yaffle."

...

spec.metadata["source_code_uri"] = "http://example.com"
spec.metadata["changelog_uri"] = "http://example.com"
```

然後運行`bundle install`命令。

現在，您可以使用`bin/test`命令運行測試，您應該看到：

```bash
$ bin/test
...
1 runs, 1 assertions, 0 failures, 0 errors, 0 skips
```

這將告訴您一切都生成正確，您已經準備好開始添加功能了。

擴展核心類
--------

本節將解釋如何向String添加一個在Rails應用程序中任何地方都可用的方法。

在此示例中，您將向String添加一個名為`to_squawk`的方法。首先，創建一個帶有幾個斷言的新測試文件：

```ruby
# yaffle/test/core_ext_test.rb

require "test_helper"

class CoreExtTest < ActiveSupport::TestCase
  def test_to_squawk_prepends_the_word_squawk
    assert_equal "squawk! Hello World", "Hello World".to_squawk
  end
end
```

運行`bin/test`命令來運行測試。這個測試應該會失敗，因為我們還沒有實現`to_squawk`方法：

```bash
$ bin/test
E

Error:
CoreExtTest#test_to_squawk_prepends_the_word_squawk:
NoMethodError: undefined method `to_squawk' for "Hello World":String


bin/test /path/to/yaffle/test/core_ext_test.rb:4

.

Finished in 0.003358s, 595.6483 runs/s, 297.8242 assertions/s.
2 runs, 1 assertions, 0 failures, 1 errors, 0 skips
```

太好了-現在您已經準備開始開發了。

在`lib/yaffle.rb`中，添加`require "yaffle/core_ext"`：

```ruby
# yaffle/lib/yaffle.rb

require "yaffle/version"
require "yaffle/railtie"
require "yaffle/core_ext"

module Yaffle
  # Your code goes here...
end
```

最後，創建`core_ext.rb`文件並添加`to_squawk`方法：

```ruby
# yaffle/lib/yaffle/core_ext.rb

class String
  def to_squawk
    "squawk! #{self}".strip
  end
end
```

為了測試您的方法是否按照所說的那樣工作，從插件目錄運行單元測試`bin/test`。

```
$ bin/test
...
2 runs, 2 assertions, 0 failures, 0 errors, 0 skips
```

要看到這個方法的效果，切換到`test/dummy`目錄，啟動`bin/rails console`，然後開始發出尖叫聲：

```irb
irb> "Hello World".to_squawk
=> "squawk! Hello World"
```

向Active Record添加"acts_as"方法
--------------------------

插件中的一個常見模式是向模型添加一個名為`acts_as_something`的方法。在這種情況下，您希望編寫一個名為`acts_as_yaffle`的方法，該方法將向Active Record模型添加一個`squawk`方法。

首先，設置您的文件，以便擁有以下內容：

```ruby
# yaffle/test/acts_as_yaffle_test.rb

require "test_helper"

class ActsAsYaffleTest < ActiveSupport::TestCase
end
```

```ruby
# yaffle/lib/yaffle.rb

require "yaffle/version"
require "yaffle/railtie"
require "yaffle/core_ext"
require "yaffle/acts_as_yaffle"

module Yaffle
  # Your code goes here...
end
```

```ruby
# yaffle/lib/yaffle/acts_as_yaffle.rb

module Yaffle
  module ActsAsYaffle
  end
end
```
### 新增一個類別方法

這個插件預期你已經在你的模型中新增了一個名為 `last_squawk` 的方法。然而，插件使用者可能已經在他們的模型中定義了一個名為 `last_squawk` 的方法，用於其他用途。這個插件允許通過新增一個名為 `yaffle_text_field` 的類別方法來更改名稱。

首先，撰寫一個失敗的測試來展示你想要的行為：

```ruby
# yaffle/test/acts_as_yaffle_test.rb

require "test_helper"

class ActsAsYaffleTest < ActiveSupport::TestCase
  def test_a_hickwalls_yaffle_text_field_should_be_last_squawk
    assert_equal "last_squawk", Hickwall.yaffle_text_field
  end

  def test_a_wickwalls_yaffle_text_field_should_be_last_tweet
    assert_equal "last_tweet", Wickwall.yaffle_text_field
  end
end
```

執行 `bin/test`，你應該會看到以下結果：

```bash
$ bin/test
# Running:

..E

Error:
ActsAsYaffleTest#test_a_wickwalls_yaffle_text_field_should_be_last_tweet:
NameError: uninitialized constant ActsAsYaffleTest::Wickwall


bin/test /path/to/yaffle/test/acts_as_yaffle_test.rb:8

E

Error:
ActsAsYaffleTest#test_a_hickwalls_yaffle_text_field_should_be_last_squawk:
NameError: uninitialized constant ActsAsYaffleTest::Hickwall


bin/test /path/to/yaffle/test/acts_as_yaffle_test.rb:4



Finished in 0.004812s, 831.2949 runs/s, 415.6475 assertions/s.
4 runs, 2 assertions, 0 failures, 2 errors, 0 skips
```

這告訴我們我們沒有我們正在嘗試測試的必要模型（Hickwall 和 Wickwall）。我們可以通過在我們的「虛擬」Rails應用程式中運行以下命令來輕鬆生成這些模型：

```bash
$ cd test/dummy
$ bin/rails generate model Hickwall last_squawk:string
$ bin/rails generate model Wickwall last_squawk:string last_tweet:string
```

現在，你可以通過進入你的虛擬應用程式並遷移數據庫來在測試數據庫中創建必要的數據表。首先，運行：

```bash
$ cd test/dummy
$ bin/rails db:migrate
```

同時，修改 Hickwall 和 Wickwall 模型，讓它們知道它們應該像 yaffles 一樣運作。

```ruby
# test/dummy/app/models/hickwall.rb

class Hickwall < ApplicationRecord
  acts_as_yaffle
end
```

```ruby
# test/dummy/app/models/wickwall.rb

class Wickwall < ApplicationRecord
  acts_as_yaffle yaffle_text_field: :last_tweet
end
```

我們還將添加代碼來定義 `acts_as_yaffle` 方法。

```ruby
# yaffle/lib/yaffle/acts_as_yaffle.rb

module Yaffle
  module ActsAsYaffle
    extend ActiveSupport::Concern

    class_methods do
      def acts_as_yaffle(options = {})
      end
    end
  end
end
```

```ruby
# test/dummy/app/models/application_record.rb

class ApplicationRecord < ActiveRecord::Base
  include Yaffle::ActsAsYaffle

  self.abstract_class = true
end
```

然後返回到你的插件根目錄（`cd ../..`），並使用 `bin/test` 重新運行測試。

```bash
$ bin/test
# Running:

.E

Error:
ActsAsYaffleTest#test_a_hickwalls_yaffle_text_field_should_be_last_squawk:
NoMethodError: undefined method `yaffle_text_field' for #<Class:0x0055974ebbe9d8>


bin/test /path/to/yaffle/test/acts_as_yaffle_test.rb:4

E

Error:
ActsAsYaffleTest#test_a_wickwalls_yaffle_text_field_should_be_last_tweet:
NoMethodError: undefined method `yaffle_text_field' for #<Class:0x0055974eb8cfc8>


bin/test /path/to/yaffle/test/acts_as_yaffle_test.rb:8

.

Finished in 0.008263s, 484.0999 runs/s, 242.0500 assertions/s.
4 runs, 2 assertions, 0 failures, 2 errors, 0 skips
```

越來越接近了... 現在，我們將實現 `acts_as_yaffle` 方法的代碼，使測試通過。

```ruby
# yaffle/lib/yaffle/acts_as_yaffle.rb

module Yaffle
  module ActsAsYaffle
    extend ActiveSupport::Concern

    class_methods do
      def acts_as_yaffle(options = {})
        cattr_accessor :yaffle_text_field, default: (options[:yaffle_text_field] || :last_squawk).to_s
      end
    end
  end
end
```

```ruby
# test/dummy/app/models/application_record.rb

class ApplicationRecord < ActiveRecord::Base
  include Yaffle::ActsAsYaffle

  self.abstract_class = true
end
```

再次運行 `bin/test`，你應該會看到所有測試都通過：

```bash
$ bin/test
...
4 runs, 4 assertions, 0 failures, 0 errors, 0 skips
```

### 新增一個實例方法

這個插件將在調用 `acts_as_yaffle` 的任何 Active Record 物件中添加一個名為 'squawk' 的方法。'squawk' 方法將簡單地設置數據庫中的一個字段的值。

首先，撰寫一個失敗的測試來展示你想要的行為：

```ruby
# yaffle/test/acts_as_yaffle_test.rb
require "test_helper"

class ActsAsYaffleTest < ActiveSupport::TestCase
  def test_a_hickwalls_yaffle_text_field_should_be_last_squawk
    assert_equal "last_squawk", Hickwall.yaffle_text_field
  end

  def test_a_wickwalls_yaffle_text_field_should_be_last_tweet
    assert_equal "last_tweet", Wickwall.yaffle_text_field
  end

  def test_hickwalls_squawk_should_populate_last_squawk
    hickwall = Hickwall.new
    hickwall.squawk("Hello World")
    assert_equal "squawk! Hello World", hickwall.last_squawk
  end

  def test_wickwalls_squawk_should_populate_last_tweet
    wickwall = Wickwall.new
    wickwall.squawk("Hello World")
    assert_equal "squawk! Hello World", wickwall.last_tweet
  end
end
```

運行測試，確保最後兩個測試失敗，並出現包含 "NoMethodError: undefined method \`squawk'" 的錯誤，然後更新 `acts_as_yaffle.rb` 如下：

```ruby
# yaffle/lib/yaffle/acts_as_yaffle.rb

module Yaffle
  module ActsAsYaffle
    extend ActiveSupport::Concern

    included do
      def squawk(string)
        write_attribute(self.class.yaffle_text_field, string.to_squawk)
      end
    end

    class_methods do
      def acts_as_yaffle(options = {})
        cattr_accessor :yaffle_text_field, default: (options[:yaffle_text_field] || :last_squawk).to_s
      end
    end
  end
end
```

```ruby
# test/dummy/app/models/application_record.rb

class ApplicationRecord < ActiveRecord::Base
  include Yaffle::ActsAsYaffle

  self.abstract_class = true
end
```

再次運行 `bin/test`，你應該會看到：

```bash
$ bin/test
...
6 runs, 6 assertions, 0 failures, 0 errors, 0 skips
```

注意：使用 `write_attribute` 方法在模型中寫入字段只是插件與模型交互的一個示例，並不總是適用的方法。例如，你也可以使用：
```ruby
send("#{self.class.yaffle_text_field}=", string.to_squawk)
```

產生器
----------

在你的插件中，你可以通過在 `lib/generators` 目錄中創建它們來包含產生器。有關產生器創建的更多信息，請參閱[產生器指南](generators.html)。

發布你的寶石
-------------------

目前正在開發中的寶石插件可以從任何 Git 存儲庫中輕鬆共享。要與其他人共享 Yaffle 寶石，只需將代碼提交到 Git 存儲庫（如 GitHub），並在相應應用程序的 `Gemfile` 中添加一行：

```ruby
gem "yaffle", git: "https://github.com/rails/yaffle.git"
```

運行 `bundle install` 後，你的寶石功能將對應用程序可用。

當寶石準備好作為正式版本共享時，可以將其發布到[RubyGems](https://rubygems.org)。

或者，你可以從 Bundler 的 Rake 任務中受益。你可以使用以下命令查看完整列表：

```bash
$ bundle exec rake -T

$ bundle exec rake build
# 將 yaffle-0.1.0.gem 构建到 pkg 目錄中

$ bundle exec rake install
# 將 yaffle-0.1.0.gem 构建並安裝到系統寶石中

$ bundle exec rake release
# 創建標籤 v0.1.0，並將 yaffle-0.1.0.gem 构建並推送到 Rubygems
```

有關將寶石發布到 RubyGems 的更多信息，請參閱：[發布你的寶石](https://guides.rubygems.org/publishing)。

RDoc 文檔
------------------

一旦你的插件穩定下來，並且你準備部署，請幫助其他人編寫文檔！幸運的是，為插件編寫文檔很容易。

第一步是使用詳細信息更新 README 文件，說明如何使用你的插件。一些關鍵的事項包括：

* 你的名字
* 如何安裝
* 如何將功能添加到應用程序中（幾個常見用例的示例）
* 可能幫助用戶並節省時間的警告、注意事項或提示

一旦你的 README 文件完善，請遍歷並為開發人員將使用的所有方法添加 RDoc 註釋。通常還會在不包含在公共 API 中的代碼部分添加 `# :nodoc:` 註釋。

一旦你的註釋準備就緒，切換到插件目錄並運行：

```bash
$ bundle exec rake rdoc
```

### 參考資料

* [使用 Bundler 開發 RubyGem](https://github.com/radar/guides/blob/master/gem-development.md)
* [按預期使用 .gemspecs](https://yehudakatz.com/2010/04/02/using-gemspecs-as-intended/)
* [Gemspec 參考](https://guides.rubygems.org/specification-reference/)
