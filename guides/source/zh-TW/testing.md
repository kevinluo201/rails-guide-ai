**DO NOT READ THIS FILE ON GITHUB, GUIDES ARE PUBLISHED ON https://guides.rubyonrails.org.**, original file md5: 6da9945dc313b748574b8aca256f1435
測試 Rails 應用程式
====================

本指南介紹了 Rails 中用於測試應用程式的內建機制。

閱讀本指南後，您將了解：

* Rails 測試術語。
* 如何為應用程式撰寫單元測試、功能測試、整合測試和系統測試。
* 其他流行的測試方法和插件。

--------------------------------------------------------------------------------

為什麼要為 Rails 應用程式撰寫測試？
------------------------------------

Rails 讓撰寫測試變得非常容易。在您建立模型和控制器時，它會為您生成測試的基本程式碼。

透過執行 Rails 測試，您可以確保即使進行了一些重大的程式碼重構，您的程式碼仍符合所需的功能。

Rails 測試還可以模擬瀏覽器請求，因此您可以在不必透過瀏覽器測試的情況下測試應用程式的回應。

測試簡介
--------

測試支援從一開始就被納入了 Rails 的架構中。這不是一個「哦！讓我們添加支援執行測試，因為它們是新的和酷的」的頓悟。

### Rails 從一開始就為測試做好準備

在使用 `rails new` _application_name_ 建立 Rails 專案時，Rails 會為您創建一個 `test` 目錄。如果列出此目錄的內容，您將看到：

```bash
$ ls -F test
application_system_test_case.rb  controllers/                     helpers/                         mailers/                         system/
channels/                        fixtures/                        integration/                     models/                          test_helper.rb
```

`helpers`、`mailers` 和 `models` 目錄分別用於保存視圖助手、郵件和模型的測試。`channels` 目錄用於保存 Action Cable 連接和頻道的測試。`controllers` 目錄用於保存控制器、路由和視圖的測試。`integration` 目錄用於保存控制器之間的交互測試。

系統測試目錄用於進行應用程式的完整瀏覽器測試。系統測試允許您以使用者體驗的方式測試應用程式，並幫助您測試 JavaScript。系統測試繼承自 Capybara，可為應用程式執行瀏覽器測試。

夾具是一種組織測試數據的方式，它們位於 `fixtures` 目錄中。

當首次生成相關的測試時，還會創建一個 `jobs` 目錄。

`test_helper.rb` 文件保存了測試的默認配置。

`application_system_test_case.rb` 文件保存了系統測試的默認配置。

### 測試環境

預設情況下，每個 Rails 應用程式都有三個環境：開發、測試和生產。

每個環境的配置可以進行類似的修改。在這種情況下，我們可以通過修改 `config/environments/test.rb` 中的選項來修改測試環境。

注意：您的測試是在 `RAILS_ENV=test` 下運行的。

### Rails 遇見 Minitest

如果您還記得，在 [Rails 入門指南](getting_started.html) 中，我們使用了 `bin/rails generate model` 命令。我們創建了我們的第一個模型，並在 `test` 目錄中創建了測試樣板：

```bash
$ bin/rails generate model article title:string body:text
...
create  app/models/article.rb
create  test/models/article_test.rb
create  test/fixtures/articles.yml
...
```

`test/models/article_test.rb` 中的默認測試樣板如下所示：

```ruby
require "test_helper"

class ArticleTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
end
```

逐行檢查此文件將幫助您瞭解 Rails 測試程式碼和術語。

```ruby
require "test_helper"
```

通過引入此文件 `test_helper.rb`，我們加載了運行測試的默認配置。我們將在撰寫的所有測試中包含此文件，因此此文件中添加的任何方法都可在所有測試中使用。

```ruby
class ArticleTest < ActiveSupport::TestCase
```

`ArticleTest` 類定義了一個「測試案例」，因為它繼承自 `ActiveSupport::TestCase`。`ArticleTest` 因此具有 `ActiveSupport::TestCase` 提供的所有方法。在本指南的後面，我們將看到其中一些方法。

在從 `Minitest::Test` 繼承的類中定義的任何以 `test_` 開頭的方法都被稱為測試。因此，以 `test_password` 和 `test_valid_password` 定義的方法是合法的測試名稱，並且在執行測試案例時會自動運行。

Rails 還添加了一個 `test` 方法，它接受測試名稱和一個區塊。它生成一個普通的 `Minitest::Unit` 測試，方法名以 `test_` 為前綴。因此，您不必擔心命名方法，可以編寫如下的代碼：

```ruby
test "the truth" do
  assert true
end
```

這與編寫以下代碼大致相同：
```ruby
def 測試真實性
  斷言 真
end
```

雖然你仍然可以使用常規的方法定義，但使用`test`宏可以使測試名稱更易讀。

注意：方法名是通過將空格替換為下劃線生成的。結果不需要是有效的Ruby標識符，因為在Ruby中，技術上任何字符串都可以是方法名。這可能需要使用`define_method`和`send`調用才能正常工作，但在形式上對名稱的限制很少。

接下來，讓我們來看看我們的第一個斷言：

```ruby
斷言 真
```

斷言是一行代碼，用於評估對象（或表達式）的預期結果。例如，斷言可以檢查：

- 這個值是否等於那個值？
- 這個對象是否為nil？
- 這行代碼是否引發異常？
- 用戶的密碼是否大於5個字符？

每個測試可能包含一個或多個斷言，對於允許多少斷言沒有限制。只有當所有斷言都成功時，測試才會通過。

#### 第一個失敗的測試

為了查看測試失敗的報告，您可以將一個失敗的測試添加到`article_test.rb`測試用例中。

```ruby
test "應該沒有標題時無法保存文章" do
  文章 = Article.new
  斷言_不是 文章.save
end
```

讓我們運行這個新添加的測試（其中`6`是定義測試的行號）。

```bash
$ bin/rails test test/models/article_test.rb:6
運行選項: --seed 44656

# 運行中:

F

失敗:
ArticleTest#test_should_not_save_article_without_title [/path/to/blog/test/models/article_test.rb:6]:
預期為true，但實際為nil或false


bin/rails test test/models/article_test.rb:6



完成於 0.023918s，41.8090 次運行/秒，41.8090 斷言/秒。

1 次運行，1 斷言，1 失敗，0 錯誤，0 跳過
```

在輸出中，`F`表示失敗。您可以看到相應的跟踪顯示在`Failure`下面，並顯示失敗測試的名稱。接下來的幾行包含堆棧跟踪，然後是一條消息，提到斷言的實際值和預期值。默認的斷言消息提供了足夠的信息來幫助定位錯誤。為了使斷言失敗消息更易讀，每個斷言都提供了一個可選的消息參數，如下所示：

```ruby
test "應該沒有標題時無法保存文章" do
  文章 = Article.new
  斷言_不是 文章.save, "保存了沒有標題的文章"
end
```

運行此測試將顯示更友好的斷言消息：

```
失敗:
ArticleTest#test_should_not_save_article_without_title [/path/to/blog/test/models/article_test.rb:6]:
保存了沒有標題的文章
```

現在，為了使此測試通過，我們可以為_title_字段添加模型級驗證。

```ruby
class Article < ApplicationRecord
  validates :title, presence: true
end
```

現在測試應該通過。讓我們再次運行測試來驗證：

```bash
$ bin/rails test test/models/article_test.rb:6
運行選項: --seed 31252

# 運行中:

.

完成於 0.027476s，36.3952 次運行/秒，36.3952 斷言/秒。

1 次運行，1 斷言，0 失敗，0 錯誤，0 跳過
```

現在，如果您注意到，我們首先編寫了一個測試，該測試對所需的功能失敗，然後我們編寫了一些代碼來添加功能，最後我們確保我們的測試通過。這種軟件開發方法稱為
[_測試驅動開發_（TDD）](http://c2.com/cgi/wiki?TestDrivenDevelopment)。

#### 錯誤的樣子

為了查看錯誤報告的方式，這裡有一個包含錯誤的測試：

```ruby
test "應該報告錯誤" do
  # some_undefined_variable在測試用例中未定義
  some_undefined_variable
  斷言 真
end
```

現在，您可以在控制台中看到運行測試時更多的輸出：

```bash
$ bin/rails test test/models/article_test.rb
運行選項: --seed 1808

# 運行中:

.E

錯誤:
ArticleTest#test_should_report_error:
NameError: undefined local variable or method 'some_undefined_variable' for #<ArticleTest:0x007fee3aa71798>
    test/models/article_test.rb:11:in 'block in <class:ArticleTest>'


bin/rails test test/models/article_test.rb:9



完成於 0.040609s，49.2500 次運行/秒，24.6250 斷言/秒。

2 次運行，1 斷言，0 失敗，1 錯誤，0 跳過
```

注意輸出中的'E'。它表示有錯誤的測試。

注意：每個測試方法的執行在遇到任何錯誤或斷言失敗時立即停止，並且測試套件繼續執行下一個方法。所有測試方法以隨機順序執行。可以使用[`config.active_support.test_order`][]選項來配置測試順序。

當測試失敗時，您將看到相應的回溯。默認情況下，Rails會過濾該回溯並僅打印與您的應用程序相關的行。這消除了框架噪音，有助於專注於您的代碼。但是，在某些情況下，您希望查看完整的回溯。設置`-b`（或`--backtrace`）參數以啟用此行為：
```bash
$ bin/rails test -b test/models/article_test.rb
```

如果我們想要通過這個測試，我們可以修改它使用 `assert_raises`，像這樣：

```ruby
test "應該報錯" do
  # some_undefined_variable 在測試案例中未定義
  assert_raises(NameError) do
    some_undefined_variable
  end
end
```

這個測試現在應該通過了。


### 可用的斷言

到目前為止，您已經瞥見了一些可用的斷言。斷言是測試的工作蜜蜂。它們是實際執行檢查以確保事情按計劃進行的工具。

以下是您可以在 Rails 使用的預設測試庫 [`Minitest`](https://github.com/minitest/minitest) 中使用的斷言的摘要。`[msg]` 參數是一個可選的字符串訊息，您可以指定它以使測試失敗訊息更清晰。

| 斷言                                                         | 目的 |
| ------------------------------------------------------------ | ---- |
| `assert( test, [msg] )`                                      | 確保 `test` 是 true。|
| `assert_not( test, [msg] )`                                  | 確保 `test` 是 false。|
| `assert_equal( expected, actual, [msg] )`                    | 確保 `expected == actual` 是 true。|
| `assert_not_equal( expected, actual, [msg] )`                | 確保 `expected != actual` 是 true。|
| `assert_same( expected, actual, [msg] )`                     | 確保 `expected.equal?(actual)` 是 true。|
| `assert_not_same( expected, actual, [msg] )`                 | 確保 `expected.equal?(actual)` 是 false。|
| `assert_nil( obj, [msg] )`                                   | 確保 `obj.nil?` 是 true。|
| `assert_not_nil( obj, [msg] )`                               | 確保 `obj.nil?` 是 false。|
| `assert_empty( obj, [msg] )`                                 | 確保 `obj` 是 `empty?`。|
| `assert_not_empty( obj, [msg] )`                             | 確保 `obj` 不是 `empty?`。|
| `assert_match( regexp, string, [msg] )`                      | 確保字串符合正則表達式。|
| `assert_no_match( regexp, string, [msg] )`                   | 確保字串不符合正則表達式。|
| `assert_includes( collection, obj, [msg] )`                  | 確保 `obj` 在 `collection` 中。|
| `assert_not_includes( collection, obj, [msg] )`              | 確保 `obj` 不在 `collection` 中。|
| `assert_in_delta( expected, actual, [delta], [msg] )`        | 確保數字 `expected` 和 `actual` 相差不超過 `delta`。|
| `assert_not_in_delta( expected, actual, [delta], [msg] )`    | 確保數字 `expected` 和 `actual` 相差超過 `delta`。|
| `assert_in_epsilon ( expected, actual, [epsilon], [msg] )`   | 確保數字 `expected` 和 `actual` 的相對誤差小於 `epsilon`。|
| `assert_not_in_epsilon ( expected, actual, [epsilon], [msg] )` | 確保數字 `expected` 和 `actual` 的相對誤差不小於 `epsilon`。|
| `assert_throws( symbol, [msg] ) { block }`                   | 確保給定的區塊拋出指定的符號。|
| `assert_raises( exception1, exception2, ... ) { block }`     | 確保給定的區塊拋出給定的例外之一。|
| `assert_instance_of( class, obj, [msg] )`                    | 確保 `obj` 是 `class` 的實例。|
| `assert_not_instance_of( class, obj, [msg] )`                | 確保 `obj` 不是 `class` 的實例。|
| `assert_kind_of( class, obj, [msg] )`                        | 確保 `obj` 是 `class` 的實例或是其子類。|
| `assert_not_kind_of( class, obj, [msg] )`                    | 確保 `obj` 不是 `class` 的實例且不是其子類。|
| `assert_respond_to( obj, symbol, [msg] )`                    | 確保 `obj` 回應 `symbol`。|
| `assert_not_respond_to( obj, symbol, [msg] )`                | 確保 `obj` 不回應 `symbol`。|
| `assert_operator( obj1, operator, [obj2], [msg] )`           | 確保 `obj1.operator(obj2)` 是 true。|
| `assert_not_operator( obj1, operator, [obj2], [msg] )`       | 確保 `obj1.operator(obj2)` 是 false。|
| `assert_predicate ( obj, predicate, [msg] )`                 | 確保 `obj.predicate` 是 true，例如 `assert_predicate str, :empty?`|
| `assert_not_predicate ( obj, predicate, [msg] )`             | 確保 `obj.predicate` 是 false，例如 `assert_not_predicate str, :empty?`|
| `flunk( [msg] )`                                             | 強制測試失敗。這對於明確標記尚未完成的測試很有用。|

上述是 minitest 支援的斷言的子集。有關詳盡且更全面的列表，請參閱 [Minitest API 文件](http://docs.seattlerb.org/minitest/)，特別是 [`Minitest::Assertions`](http://docs.seattlerb.org/minitest/Minitest/Assertions.html)。

由於測試框架的模塊化特性，您可以創建自己的斷言。事實上，這正是 Rails 所做的。它包含一些專門的斷言，以使您的生活更輕鬆。

注意：創建自己的斷言是一個高級主題，在本教程中我們不會涵蓋。

### Rails 專用斷言

Rails 在 `minitest` 框架中添加了一些自己的自訂斷言：
| 斷言                                                                                   | 目的     |
| ------------------------------------------------------------------------------------- | ------- |
| [`assert_difference(expressions, difference = 1, message = nil) {...}`](https://api.rubyonrails.org/classes/ActiveSupport/Testing/Assertions.html#method-i-assert_difference) | 測試在執行傳入的區塊後，表達式的返回值之間的數值差異。|
| [`assert_no_difference(expressions, message = nil, &block)`](https://api.rubyonrails.org/classes/ActiveSupport/Testing/Assertions.html#method-i-assert_no_difference) | 斷言在調用傳入的區塊之前和之後，評估表達式的數值結果沒有改變。|
| [`assert_changes(expressions, message = nil, from:, to:, &block)`](https://api.rubyonrails.org/classes/ActiveSupport/Testing/Assertions.html#method-i-assert_changes) | 測試在調用傳入的區塊後，評估表達式的結果是否改變。|
| [`assert_no_changes(expressions, message = nil, &block)`](https://api.rubyonrails.org/classes/ActiveSupport/Testing/Assertions.html#method-i-assert_no_changes) | 測試在調用傳入的區塊後，評估表達式的結果是否沒有改變。|
| [`assert_nothing_raised { block }`](https://api.rubyonrails.org/classes/ActiveSupport/Testing/Assertions.html#method-i-assert_nothing_raised) | 確保給定的區塊不會引發任何異常。|
| [`assert_recognizes(expected_options, path, extras={}, message=nil)`](https://api.rubyonrails.org/classes/ActionDispatch/Assertions/RoutingAssertions.html#method-i-assert_recognizes) | 斷言給定路徑的路由處理正確，並且解析的選項（在expected_options哈希中給出）與路徑匹配。基本上，它斷言Rails能夠識別出由expected_options給出的路由。|
| [`assert_generates(expected_path, options, defaults={}, extras = {}, message=nil)`](https://api.rubyonrails.org/classes/ActionDispatch/Assertions/RoutingAssertions.html#method-i-assert_generates) | 斷言提供的選項可以用於生成提供的路徑。這是assert_recognizes的相反操作。extras參數用於告訴請求查詢字符串中的其他請求參數的名稱和值。message參數允許您為斷言失敗指定自定義錯誤消息。|
| [`assert_response(type, message = nil)`](https://api.rubyonrails.org/classes/ActionDispatch/Assertions/ResponseAssertions.html#method-i-assert_response) | 斷言響應具有特定的狀態碼。您可以指定`:success`表示200-299，`:redirect`表示300-399，`:missing`表示404，或者`:error`表示500-599範圍。您還可以傳遞明確的狀態碼或其符號等效。有關更多信息，請參閱[完整的狀態碼列表](https://rubydoc.info/gems/rack/Rack/Utils#HTTP_STATUS_CODES-constant)以及它們的[映射](https://rubydoc.info/gems/rack/Rack/Utils#SYMBOL_TO_STATUS_CODE-constant)如何工作。|
| [`assert_redirected_to(options = {}, message=nil)`](https://api.rubyonrails.org/classes/ActionDispatch/Assertions/ResponseAssertions.html#method-i-assert_redirected_to) | 斷言響應是重定向到與給定選項匹配的URL。您還可以傳遞命名路由，例如`assert_redirected_to root_path`，以及Active Record對象，例如`assert_redirected_to @article`。|

您將在下一章中看到這些斷言的使用方法。

### 關於測試用例的簡要說明

所有基本的斷言，如`assert_equal`在我們自己的測試用例中使用的類中也是可用的。實際上，Rails為您提供了以下類供您繼承：

* [`ActiveSupport::TestCase`](https://api.rubyonrails.org/classes/ActiveSupport/TestCase.html)
* [`ActionMailer::TestCase`](https://api.rubyonrails.org/classes/ActionMailer/TestCase.html)
* [`ActionView::TestCase`](https://api.rubyonrails.org/classes/ActionView/TestCase.html)
* [`ActiveJob::TestCase`](https://api.rubyonrails.org/classes/ActiveJob/TestCase.html)
* [`ActionDispatch::IntegrationTest`](https://api.rubyonrails.org/classes/ActionDispatch/IntegrationTest.html)
* [`ActionDispatch::SystemTestCase`](https://api.rubyonrails.org/classes/ActionDispatch/SystemTestCase.html)
* [`Rails::Generators::TestCase`](https://api.rubyonrails.org/classes/Rails/Generators/TestCase.html)

這些類中包含`Minitest::Assertions`，允許我們在測試中使用所有基本的斷言。

注意：有關`Minitest`的更多信息，請參閱[其文檔](http://docs.seattlerb.org/minitest)。

### Rails測試運行器

我們可以使用`bin/rails test`命令一次運行所有測試。

或者，通過將`bin/rails test`命令與包含測試用例的文件名一起使用，可以運行單個測試文件。

```bash
$ bin/rails test test/models/article_test.rb
Run options: --seed 1559

# Running:

..

Finished in 0.027034s, 73.9810 runs/s, 110.9715 assertions/s.

2 runs, 3 assertions, 0 failures, 0 errors, 0 skips
```

這將運行測試用例中的所有測試方法。

您還可以通過提供`-n`或`--name`標誌和測試方法的名稱，從測試用例中運行特定的測試方法。

```bash
$ bin/rails test test/models/article_test.rb -n test_the_truth
Run options: -n test_the_truth --seed 43583

# Running:

.

Finished tests in 0.009064s, 110.3266 tests/s, 110.3266 assertions/s.

1 tests, 1 assertions, 0 failures, 0 errors, 0 skips
```

您還可以通過提供行號，運行特定行的測試。

```bash
$ bin/rails test test/models/article_test.rb:6 # 運行特定的測試和行號
```

您還可以通過提供目錄的路徑，運行整個目錄的測試。

```bash
$ bin/rails test test/controllers # 運行特定目錄中的所有測試
```

測試運行器還提供了許多其他功能，例如快速失敗、在測試運行結束後延遲測試輸出等。請查看測試運行器的文檔，如下所示：

```bash
$ bin/rails test -h
Usage: rails test [options] [files or directories]

You can run a single test by appending a line number to a filename:

    bin/rails test test/models/user_test.rb:27

You can run multiple files and directories at the same time:

    bin/rails test test/controllers test/integration/login_test.rb

By default test failures and errors are reported inline during a run.

minitest options:
    -h, --help                       Display this help.
        --no-plugins                 Bypass minitest plugin auto-loading (or set $MT_NO_PLUGINS).
    -s, --seed SEED                  Sets random seed. Also via env. Eg: SEED=n rake
    -v, --verbose                    Verbose. Show progress processing files.
    -n, --name PATTERN               Filter run on /regexp/ or string.
        --exclude PATTERN            Exclude /regexp/ or string from run.

Known extensions: rails, pride
    -w, --warnings                   Run with Ruby warnings enabled
    -e, --environment ENV            Run tests in the ENV environment
    -b, --backtrace                  Show the complete backtrace
    -d, --defer-output               Output test failures and errors after the test run
    -f, --fail-fast                  Abort test run on first failure or error
    -c, --[no-]color                 Enable color in the output
    -p, --pride                      Pride. Show your testing pride!
```
### 在持續整合（CI）中運行測試

要在CI環境中運行所有測試，只需要一個命令：

```bash
$ bin/rails test
```

如果您正在使用[系統測試](#system-testing)，`bin/rails test`將不會運行它們，因為它們可能會很慢。要運行它們，可以添加另一個CI步驟來運行`bin/rails test:system`，或者將第一個步驟更改為`bin/rails test:all`，這將運行包括系統測試在內的所有測試。

並行測試
----------------

並行測試允許您將測試套件並行化。雖然默認方法是使用Ruby的DRb系統分叉進程，但也支持線程。並行運行測試可以減少整個測試套件運行所需的時間。

### 使用進程進行並行測試

默認的並行化方法是使用Ruby的DRb系統分叉進程。這些進程是基於提供的工作程序數進行分叉的。默認數量是您所在機器上的實際核心數，但可以通過傳遞給parallelize方法的數字進行更改。

要啟用並行化，請將以下代碼添加到您的`test_helper.rb`中：

```ruby
class ActiveSupport::TestCase
  parallelize(workers: 2)
end
```

傳遞的工作程序數是進程分叉的次數。您可能希望以與CI不同的方式並行化本地測試套件，因此提供了一個環境變量，以便能夠輕鬆更改測試運行應使用的工作程序數：

```bash
$ PARALLEL_WORKERS=15 bin/rails test
```

在並行化測試時，Active Record會自動處理為每個進程創建數據庫並將模式加載到數據庫中。數據庫將以與工作程序相對應的數字作為後綴。例如，如果您有2個工作程序，則測試將分別創建`test-database-0`和`test-database-1`。

如果傳遞的工作程序數為1或更少，則不會分叉進程，測試將不會並行化，並且測試將使用原始的`test-database`數據庫。

提供了兩個鉤子，一個在進程分叉時運行，另一個在分叉的進程關閉之前運行。如果您的應用程序使用多個數據庫或執行依賴於工作程序數的其他任務，這些鉤子可能很有用。

`parallelize_setup`方法在進程分叉後立即調用。`parallelize_teardown`方法在進程關閉之前立即調用。

```ruby
class ActiveSupport::TestCase
  parallelize_setup do |worker|
    # 設置數據庫
  end

  parallelize_teardown do |worker|
    # 清理數據庫
  end

  parallelize(workers: :number_of_processors)
end
```

在使用線程進行並行測試時，不需要也不可用這些方法。

### 使用線程進行並行測試

如果您更喜歡使用線程，或者正在使用JRuby，則提供了一個線程並行化選項。線程並行化選項由Minitest的`Parallel::Executor`支持。

要將並行化方法更改為使用線程而不是分叉，請將以下代碼放入您的`test_helper.rb`中：

```ruby
class ActiveSupport::TestCase
  parallelize(workers: :number_of_processors, with: :threads)
end
```

從JRuby或TruffleRuby生成的Rails應用程序將自動包含`with: :threads`選項。

傳遞給`parallelize`的工作程序數確定測試將使用的線程數。您可能希望以與CI不同的方式並行化本地測試套件，因此提供了一個環境變量，以便能夠輕鬆更改測試運行應使用的工作程序數：

```bash
$ PARALLEL_WORKERS=15 bin/rails test
```

### 測試並行事務

Rails會自動將任何測試用例包裝在在測試完成後回滾的數據庫事務中。這使得測試用例彼此獨立，並且對數據庫的更改僅在單個測試中可見。

當您想要測試在線程中運行並行事務的代碼時，事務可能會相互阻塞，因為它們已經嵌套在測試事務下。

您可以通過設置`self.use_transactional_tests = false`來禁用測試用例類中的事務：

```ruby
class WorkerTest < ActiveSupport::TestCase
  self.use_transactional_tests = false

  test "parallel transactions" do
    # 啟動一些創建事務的線程
  end
end
```

注意：禁用事務測試後，您必須清理測試創建的任何數據，因為更改不會在測試完成後自動回滾。

### 並行化測試的閾值

並行運行測試會增加數據庫設置和固定裝載的開銷。因此，Rails不會對涉及少於50個測試的執行進行並行化。

您可以在`test.rb`中配置此閾值：
```ruby
config.active_support.test_parallelization_threshold = 100
```

同時，在設定測試案例層級的並行化時：

```ruby
class ActiveSupport::TestCase
  parallelize threshold: 100
end
```

測試資料庫
-----------------

幾乎每個 Rails 應用程式都與資料庫有密切的互動，因此您的測試也需要與資料庫互動。為了撰寫有效的測試，您需要了解如何設定這個資料庫並填充它的範例資料。

預設情況下，每個 Rails 應用程式都有三個環境：開發、測試和生產。每個環境的資料庫都在 `config/database.yml` 中進行配置。

專用的測試資料庫允許您在隔離環境中設定和互動測試資料。這樣，您的測試可以自信地操縱測試資料，而不必擔心開發或生產資料庫中的資料。

### 維護測試資料庫結構

為了執行測試，您的測試資料庫需要具有當前的結構。測試輔助程式會檢查您的測試資料庫是否有任何未完成的遷移。它會嘗試將您的 `db/schema.rb` 或 `db/structure.sql` 載入測試資料庫。如果遷移仍然未完成，則會引發錯誤。通常，這表示您的結構尚未完全遷移。執行遷移以將結構更新到開發資料庫 (`bin/rails db:migrate`)。

注意：如果對現有遷移進行了修改，則需要重建測試資料庫。可以通過執行 `bin/rails db:test:prepare` 來完成。

### 關於固定資料的低調

為了進行良好的測試，您需要考慮設定測試資料。在 Rails 中，您可以通過定義和自定義固定資料來處理這個問題。您可以在 [固定資料 API 文件](https://api.rubyonrails.org/classes/ActiveRecord/FixtureSet.html) 中找到全面的文件。

#### 什麼是固定資料？

固定資料是一個高級詞彙，用於表示範例資料。固定資料允許您在測試運行之前將測試資料庫填充為預定義的資料。固定資料與資料庫無關，並以 YAML 格式編寫。每個模型對應一個檔案。

注意：固定資料不是用於創建測試所需的每個物件，最好只在應用於常見情況的預設資料時使用。

您可以在 `test/fixtures` 目錄下找到固定資料。當您運行 `bin/rails generate model` 創建新模型時，Rails 會自動在此目錄中創建固定資料樣板。

#### YAML

以 YAML 格式編寫的固定資料是一種人性化的描述範例資料的方式。這些類型的固定資料具有 **.yml** 檔案擴展名（例如 `users.yml`）。

以下是一個 YAML 固定資料檔案的示例：

```yaml
# lo & behold! I am a YAML comment!
david:
  name: David Heinemeier Hansson
  birthday: 1979-10-15
  profession: Systems development

steve:
  name: Steve Ross Kellock
  birthday: 1974-09-27
  profession: guy with keyboard
```

每個固定資料都有一個名稱，後面是一個縮進的冒號分隔的鍵/值對列表。記錄通常由空行分隔。您可以使用 # 字符在固定資料檔案中添加註釋，該字符位於第一列。

如果您正在使用 [關聯](/association_basics.html)，您可以在兩個不同的固定資料之間定義一個引用節點。以下是一個具有 `belongs_to`/`has_many` 關聯的示例：

```yaml
# test/fixtures/categories.yml
about:
  name: About
```

```yaml
# test/fixtures/articles.yml
first:
  title: Welcome to Rails!
  category: about
```

```yaml
# test/fixtures/action_text/rich_texts.yml
first_content:
  record: first (Article)
  name: content
  body: <div>Hello, from <strong>a fixture</strong></div>
```

請注意，`fixtures/articles.yml` 中的 `first` Article 的 `category` 鍵的值為 `about`，而 `fixtures/action_text/rich_texts.yml` 中的 `first_content` 項目的 `record` 鍵的值為 `first (Article)`。這提示 Active Record 加載 `fixtures/categories.yml` 中找到的 Category `about`，並且提示 Action Text 加載 `fixtures/articles.yml` 中找到的 Article `first`。

注意：為了使關聯可以使用名稱相互引用，您可以使用固定資料名稱而不是在相關的固定資料上指定 `id:` 屬性。Rails 將自動分配一個主鍵以在運行之間保持一致。有關此關聯行為的更多信息，請閱讀 [固定資料 API 文件](https://api.rubyonrails.org/classes/ActiveRecord/FixtureSet.html)。

#### 檔案附件固定資料

與其他基於 Active Record 的模型一樣，Active Storage 附件記錄繼承自 ActiveRecord::Base 實例，因此可以通過固定資料填充。

考慮一個 `Article` 模型，它具有一個關聯圖片作為 `thumbnail` 附件，以及固定資料 YAML：

```ruby
class Article
  has_one_attached :thumbnail
end
```

```yaml
# test/fixtures/articles.yml
first:
  title: An Article
```

假設在`test/fixtures/files/first.png`中有一個編碼為[image/png][]的文件，以下的YAML夾具條目將生成相關的`ActiveStorage::Blob`和`ActiveStorage::Attachment`記錄：

```yaml
# test/fixtures/active_storage/blobs.yml
first_thumbnail_blob: <%= ActiveStorage::FixtureSet.blob filename: "first.png" %>
```

```yaml
# test/fixtures/active_storage/attachments.yml
first_thumbnail_attachment:
  name: thumbnail
  record: first (Article)
  blob: first_thumbnail_blob
```


#### ERB'in It Up

ERB允許您在模板中嵌入Ruby代碼。當Rails加載夾具時，YAML夾具格式將使用ERB進行預處理。這使您可以使用Ruby來生成一些示例數據。例如，以下代碼生成一千個用戶：

```erb
<% 1000.times do |n| %>
user_<%= n %>:
  username: <%= "user#{n}" %>
  email: <%= "user#{n}@example.com" %>
<% end %>
```

#### 夾具的操作

Rails默認情況下自動加載`test/fixtures`目錄中的所有夾具。加載包括三個步驟：

1. 從與夾具對應的表中刪除任何現有數據
2. 將夾具數據加載到表中
3. 將夾具數據轉儲到一個方法中，以便您可以直接訪問它

提示：為了從數據庫中刪除現有數據，Rails嘗試禁用參照完整性觸發器（如外鍵和檢查約束）。如果在運行測試時出現煩人的權限錯誤，請確保數據庫用戶在測試環境中有權限禁用這些觸發器。（在PostgreSQL中，只有超級用戶可以禁用所有觸發器。在此處閱讀有關PostgreSQL權限的更多信息[here](https://www.postgresql.org/docs/current/sql-altertable.html)）。

#### 夾具是Active Record對象

夾具是Active Record的實例。如上所述，在第3點中提到，您可以直接訪問該對象，因為它自動作為一個方法可在測試用例的本地範圍內使用。例如：

```ruby
# 這將返回名為david的夾具的User對象
users(:david)

# 這將返回名為david的屬性的id
users(:david).id

# 也可以訪問User類上可用的方法
david = users(:david)
david.call(david.partner)
```

要一次獲取多個夾具，可以傳入一個夾具名稱列表。例如：

```ruby
# 這將返回包含夾具david和steve的數組
users(:david, :steve)
```


模型測試
-------------

模型測試用於測試應用程序的各種模型。

Rails模型測試存儲在`test/models`目錄下。Rails提供了一個生成器來為您創建模型測試框架。

```bash
$ bin/rails generate test_unit:model article title:string body:text
create  test/models/article_test.rb
create  test/fixtures/articles.yml
```

模型測試沒有像`ActionMailer::TestCase`那樣有自己的超類。相反，它們繼承自[`ActiveSupport::TestCase`](https://api.rubyonrails.org/classes/ActiveSupport/TestCase.html)。

系統測試
--------------

系統測試允許您測試用戶與應用程序的交互，以真實或無頭瀏覽器運行測試。系統測試在幕後使用Capybara。

要創建Rails系統測試，您可以在應用程序中使用`test/system`目錄。Rails提供了一個生成器來為您創建系統測試框架。

```bash
$ bin/rails generate system_test users
      invoke test_unit
      create test/system/users_test.rb
```

以下是新生成的系統測試的示例：

```ruby
require "application_system_test_case"

class UsersTest < ApplicationSystemTestCase
  # test "visiting the index" do
  #   visit users_url
  #
  #   assert_selector "h1", text: "Users"
  # end
end
```

默認情況下，系統測試使用Selenium驅動程序，在Chrome瀏覽器中運行，屏幕大小為1400x1400。下一節將解釋如何更改默認設置。

### 更改默認設置

Rails使更改系統測試的默認設置變得非常簡單。所有設置都被抽象出來，因此您可以專注於編寫測試。

當您生成新的應用程序或脚手架時，將在測試目錄中創建一個`application_system_test_case.rb`文件。這是您的系統測試的所有配置應該存在的地方。

如果要更改默認設置，可以更改系統測試的“驅動程序”。假設您想將驅動程序從Selenium更改為Cuprite。首先將`cuprite` gem添加到您的`Gemfile`中。然後在您的`application_system_test_case.rb`文件中執行以下操作：

```ruby
require "test_helper"
require "capybara/cuprite"

class ApplicationSystemTestCase < ActionDispatch::SystemTestCase
  driven_by :cuprite
end
```

驅動程序名稱是`driven_by`的必需參數。可以傳遞給`driven_by`的可選參數有`：using`用於瀏覽器（這僅由Selenium使用），`：screen_size`用於更改屏幕截圖的屏幕大小，以及`：options`可用於設置驅動程序支持的選項。
```ruby
require "test_helper"

class ApplicationSystemTestCase < ActionDispatch::SystemTestCase
  driven_by :selenium, using: :firefox
end
```

如果您想使用無頭瀏覽器，您可以通過在 `:using` 參數中添加 `headless_chrome` 或 `headless_firefox` 來使用 Headless Chrome 或 Headless Firefox。

```ruby
require "test_helper"

class ApplicationSystemTestCase < ActionDispatch::SystemTestCase
  driven_by :selenium, using: :headless_chrome
end
```

如果您想使用遠程瀏覽器，例如 [Docker 中的 Headless Chrome](https://github.com/SeleniumHQ/docker-selenium)，您需要通過 `options` 添加遠程 `url`。

```ruby
require "test_helper"

class ApplicationSystemTestCase < ActionDispatch::SystemTestCase
  options = ENV["SELENIUM_REMOTE_URL"].present? ? { url: ENV["SELENIUM_REMOTE_URL"] } : {}
  driven_by :selenium, using: :headless_chrome, options: options
end
```

在這種情況下，不再需要 `webdrivers` gem。您可以完全刪除它，或者在 `Gemfile` 中添加 `require:` 選項。

```ruby
# ...
group :test do
  gem "webdrivers", require: !ENV["SELENIUM_REMOTE_URL"] || ENV["SELENIUM_REMOTE_URL"].empty?
end
```

現在您應該可以連接到遠程瀏覽器。

```bash
$ SELENIUM_REMOTE_URL=http://localhost:4444/wd/hub bin/rails test:system
```

如果您的測試應用程序也在遠程運行，例如 Docker 容器，Capybara 需要更多關於如何 [調用遠程服務器](https://github.com/teamcapybara/capybara#calling-remote-servers) 的輸入。

```ruby
require "test_helper"

class ApplicationSystemTestCase < ActionDispatch::SystemTestCase
  def setup
    Capybara.server_host = "0.0.0.0" # 綁定到所有接口
    Capybara.app_host = "http://#{IPSocket.getaddress(Socket.gethostname)}" if ENV["SELENIUM_REMOTE_URL"].present?
    super
  end
  # ...
end
```

現在，無論運行在 Docker 容器還是 CI 中，您都應該可以連接到遠程瀏覽器和服務器。

如果您的 Capybara 配置需要比 Rails 提供的更多設置，可以將這些額外配置添加到 `application_system_test_case.rb` 文件中。

有關其他設置，請參閱 [Capybara 的文檔](https://github.com/teamcapybara/capybara#setup)。

### Screenshot Helper

`ScreenshotHelper` 是一個幫助程序，用於捕獲測試的屏幕截圖。這對於在測試失敗時查看瀏覽器的情況或以後進行調試時查看屏幕截圖很有幫助。

提供了兩個方法：`take_screenshot` 和 `take_failed_screenshot`。`take_failed_screenshot` 自動包含在 Rails 的 `before_teardown` 中。

`take_screenshot` 幫助方法可以在測試的任何地方包含，以捕獲瀏覽器的屏幕截圖。

### 實現系統測試

現在，我們將在我們的博客應用程序中添加一個系統測試。我們將通過訪問索引頁面並創建一篇新的博客文章來演示如何編寫系統測試。

如果您使用了脚手架生成器，則會自動為您創建一個系統測試骨架。如果您沒有使用脚手架生成器，請首先創建一個系統測試骨架。

```bash
$ bin/rails generate system_test articles
```

它應該為我們創建了一個測試文件占位符。通過上一個命令的輸出，您應該看到：

```
      invoke  test_unit
      create    test/system/articles_test.rb
```

現在讓我們打開該文件並編寫我們的第一個斷言：

```ruby
require "application_system_test_case"

class ArticlesTest < ApplicationSystemTestCase
  test "viewing the index" do
    visit articles_path
    assert_selector "h1", text: "Articles"
  end
end
```

該測試應該看到文章索引頁面上有一個 `h1`，並通過。

運行系統測試。

```bash
$ bin/rails test:system
```

注意：默認情況下，運行 `bin/rails test` 不會運行系統測試。請確保運行 `bin/rails test:system` 來實際運行它們。您也可以運行 `bin/rails test:all` 來運行所有測試，包括系統測試。

#### 創建文章系統測試

現在，讓我們測試在我們的博客中創建一篇新文章的流程。

```ruby
test "should create Article" do
  visit articles_path

  click_on "New Article"

  fill_in "Title", with: "Creating an Article"
  fill_in "Body", with: "Created this article successfully!"

  click_on "Create Article"

  assert_text "Creating an Article"
end
```

第一步是調用 `visit articles_path`。這將使測試進入文章索引頁面。

然後，`click_on "New Article"` 將在索引頁面上找到 "New Article" 按鈕。這將重定向瀏覽器到 `/articles/new`。

然後，測試將使用指定的文本填寫文章的標題和內容。填寫字段後，點擊 "Create Article"，這將發送一個 POST 請求在數據庫中創建新文章。

我們將被重定向回文章索引頁面，並在那裡斷言新文章的標題文本在文章索引頁面上。

#### 測試多個屏幕尺寸

如果您想在測試桌面尺寸之外還測試移動尺寸，您可以創建另一個從 `ActionDispatch::SystemTestCase` 繼承的類，在測試套件中使用它。在此示例中，在 `/test` 目錄中創建了一個名為 `mobile_system_test_case.rb` 的文件，其中包含以下配置。
```ruby
require "test_helper"

class MobileSystemTestCase < ActionDispatch::SystemTestCase
  driven_by :selenium, using: :chrome, screen_size: [375, 667]
end
```

要使用這個配置，請在 `test/system` 內創建一個繼承自 `MobileSystemTestCase` 的測試。
現在，您可以使用多種不同的配置來測試您的應用程序。

```ruby
require "mobile_system_test_case"

class PostsTest < MobileSystemTestCase
  test "訪問首頁" do
    visit posts_url
    assert_selector "h1", text: "Posts"
  end
end
```

#### 更進一步

系統測試的美妙之處在於它類似於集成測試，它測試用戶與控制器、模型和視圖的交互，但系統測試更加強大，實際上測試您的應用程序，就像真正的用戶在使用它一樣。往後，您可以測試用戶在應用程序中執行的任何操作，例如評論、刪除文章、發布草稿文章等。

集成測試
-------------------

集成測試用於測試應用程序中各個部分的交互方式。它們通常用於測試應用程序中的重要工作流程。

要創建Rails集成測試，我們使用應用程序的 `test/integration` 目錄。Rails提供了一個生成器來為我們創建集成測試的骨架。

```bash
$ bin/rails generate integration_test user_flows
      exists  test/integration/
      create  test/integration/user_flows_test.rb
```

這是一個新生成的集成測試的樣子：

```ruby
require "test_helper"

class UserFlowsTest < ActionDispatch::IntegrationTest
  # test "the truth" do
  #   assert true
  # end
end
```

在這裡，測試繼承自 `ActionDispatch::IntegrationTest`。這使我們可以在集成測試中使用一些額外的輔助方法。

### 集成測試可用的輔助方法

除了標準的測試輔助方法外，從 `ActionDispatch::IntegrationTest` 繼承還提供了一些額外的輔助方法可用於編寫集成測試。讓我們簡要介紹一下這三個類別的輔助方法。

要處理集成測試運行器，請參閱 [`ActionDispatch::Integration::Runner`](https://api.rubyonrails.org/classes/ActionDispatch/Integration/Runner.html)。

在執行請求時，我們可以使用 [`ActionDispatch::Integration::RequestHelpers`](https://api.rubyonrails.org/classes/ActionDispatch/Integration/RequestHelpers.html)。

如果我們需要修改集成測試的會話或狀態，可以參考 [`ActionDispatch::Integration::Session`](https://api.rubyonrails.org/classes/ActionDispatch/Integration/Session.html)。

### 實施一個集成測試

讓我們為我們的博客應用程序添加一個集成測試。我們將從創建一個新的博客文章的基本工作流程開始，以驗證一切是否正常運作。

首先，我們生成集成測試的骨架：

```bash
$ bin/rails generate integration_test blog_flow
```

它應該為我們創建了一個測試文件的佔位符。根據前面命令的輸出，我們應該看到：

```
      invoke  test_unit
      create    test/integration/blog_flow_test.rb
```

現在讓我們打開該文件並編寫我們的第一個斷言：

```ruby
require "test_helper"

class BlogFlowTest < ActionDispatch::IntegrationTest
  test "可以看到歡迎頁面" do
    get "/"
    assert_select "h1", "Welcome#index"
  end
end
```

我們將使用 `assert_select` 查詢請求的結果HTML，詳細內容請參閱下面的 "測試視圖" 部分。它用於通過斷言關鍵HTML元素及其內容的存在來測試我們的請求響應。

當我們訪問根路徑時，我們應該看到 `welcome/index.html.erb` 被渲染為視圖。所以這個斷言應該通過。

#### 創建文章集成測試

我們如何測試在博客中創建一篇新文章並查看結果。

```ruby
test "可以創建一篇文章" do
  get "/articles/new"
  assert_response :success

  post "/articles",
    params: { article: { title: "可以創建", body: "成功創建文章。" } }
  assert_response :redirect
  follow_redirect!
  assert_response :success
  assert_select "p", "標題:\n  可以創建"
end
```

讓我們逐步解析這個測試，以便我們可以理解它。

我們首先在 Articles 控制器上調用 `:new` 動作。這個響應應該是成功的。

之後，我們對 Articles 控制器的 `:create` 動作進行了一個 post 請求：

```ruby
post "/articles",
  params: { article: { title: "可以創建", body: "成功創建文章。" } }
assert_response :redirect
follow_redirect!
```

請求後的兩行是用於處理我們在創建新文章時設置的重定向。

注意：如果您計劃在重定向後進行後續請求，不要忘記調用 `follow_redirect!`。

最後，我們可以斷言我們的響應是成功的，並且我們的新文章在頁面上可讀。

#### 更進一步

我們成功測試了訪問博客並創建一篇新文章的非常簡單的工作流程。如果我們想進一步，我們可以為評論、刪除文章或編輯評論添加測試。集成測試是我們應用程序各種用例的實驗場所。
控制器的功能測試
-------------------

在Rails中，測試控制器的各種操作是一種撰寫功能測試的形式。請記住，您的控制器處理應用程序的傳入網絡請求，並最終以渲染的視圖作出回應。在撰寫功能測試時，您正在測試操作如何處理請求以及預期的結果或回應，有時是HTML視圖。

### 功能測試中應包含的內容

您應該測試以下內容：

* 網絡請求是否成功？
* 用戶是否被重定向到正確的頁面？
* 用戶是否成功驗證？
* 視圖中是否顯示了適當的消息？
* 回應中是否顯示了正確的信息？

最直觀的了解功能測試的方法是使用腳手架生成器生成一個控制器：

```bash
$ bin/rails generate scaffold_controller article title:string body:text
...
create  app/controllers/articles_controller.rb
...
invoke  test_unit
create    test/controllers/articles_controller_test.rb
...
```

這將生成一個`Article`資源的控制器代碼和測試。您可以查看`test/controllers`目錄中的`articles_controller_test.rb`文件。

如果您已經有一個控制器，只想為每個預設操作生成測試腳手架代碼，可以使用以下命令：

```bash
$ bin/rails generate test_unit:scaffold article
...
invoke  test_unit
create    test/controllers/articles_controller_test.rb
...
```

讓我們來看一個這樣的測試，`articles_controller_test.rb`文件中的`test_should_get_index`。

```ruby
# articles_controller_test.rb
class ArticlesControllerTest < ActionDispatch::IntegrationTest
  test "should get index" do
    get articles_url
    assert_response :success
  end
end
```

在`test_should_get_index`測試中，Rails模擬了對名為`index`的操作的請求，確保請求成功，並確保生成了正確的回應內容。

`get`方法觸發網絡請求並將結果填充到`@response`中。它最多可以接受6個參數：

* 您正在請求的控制器操作的URI。這可以是字符串形式或路由輔助方法（例如`articles_url`）。
* `params`：選項，包含要傳遞到操作中的請求參數的哈希（例如查詢字符串參數或文章變量）。
* `headers`：用於設置將與請求一起傳遞的標頭。
* `env`：用於根據需要自定義請求環境。
* `xhr`：請求是否為Ajax請求。可以將其設置為true以標記請求為Ajax。
* `as`：用於使用不同內容類型對請求進行編碼。

所有這些關鍵字參數都是可選的。

示例：調用第一個`Article`的`show`操作，並傳遞`HTTP_REFERER`標頭：

```ruby
get article_url(Article.first), headers: { "HTTP_REFERER" => "http://example.com/home" }
```

另一個示例：調用最後一個`Article`的`update`操作，並在`params`中傳遞`title`的新文本，作為Ajax請求：

```ruby
patch article_url(Article.last), params: { article: { title: "updated" } }, xhr: true
```

再來一個示例：調用`create`操作以創建一篇新文章，並在`params`中傳遞`title`的文本，作為JSON請求：

```ruby
post articles_path, params: { article: { title: "Ahoy!" } }, as: :json
```

注意：如果您嘗試運行`articles_controller_test.rb`中的`test_should_create_article`測試，由於新增的模型級驗證，測試將失敗，這是正確的。

讓我們修改`articles_controller_test.rb`中的`test_should_create_article`測試，以使所有測試都通過：

```ruby
test "should create article" do
  assert_difference("Article.count") do
    post articles_url, params: { article: { body: "Rails is awesome!", title: "Hello Rails" } }
  end

  assert_redirected_to article_path(Article.last)
end
```

現在，您可以嘗試運行所有測試，它們應該通過。

注意：如果您按照[基本身份驗證](getting_started.html#basic-authentication)部分的步驟進行操作，您需要將授權添加到每個請求標頭中，以使所有測試通過：

```ruby
post articles_url, params: { article: { body: "Rails is awesome!", title: "Hello Rails" } }, headers: { Authorization: ActionController::HttpAuthentication::Basic.encode_credentials("dhh", "secret") }
```

### 功能測試中可用的請求類型

如果您熟悉HTTP協議，您將知道`get`是一種請求類型。Rails功能測試支持6種請求類型：

* `get`
* `post`
* `patch`
* `put`
* `head`
* `delete`

所有請求類型都有相應的方法可供使用。在典型的C.R.U.D.應用程序中，您將更常使用`get`、`post`、`put`和`delete`。
注意：功能測試不會驗證指定的請求類型是否被操作所接受，我們更關心的是結果。請求測試用於此用例，使您的測試更有目的性。

### 測試 XHR (Ajax) 請求

要測試 Ajax 請求，您可以在 `get`、`post`、`patch`、`put` 和 `delete` 方法中指定 `xhr: true` 選項。例如：

```ruby
test "ajax request" do
  article = articles(:one)
  get article_url(article), xhr: true

  assert_equal "hello world", @response.body
  assert_equal "text/javascript", @response.media_type
end
```

### 末日的三個哈希

在請求完成後，您將擁有 3 個準備好使用的哈希對象：

* `cookies` - 設置的任何 cookie
* `flash` - 存在於 flash 中的任何對象
* `session` - 存在於會話變量中的任何對象

與普通的哈希對象一樣，您可以通過字符串引用鍵來訪問值。您也可以通過符號名稱來引用它們。例如：

```ruby
flash["gordon"]               flash[:gordon]
session["shmession"]          session[:shmession]
cookies["are_good_for_u"]     cookies[:are_good_for_u]
```

### 可用的實例變量

在進行請求之後，您還可以在功能測試中訪問三個實例變量：

* `@controller` - 處理請求的控制器
* `@request` - 請求對象
* `@response` - 響應對象


```ruby
class ArticlesControllerTest < ActionDispatch::IntegrationTest
  test "should get index" do
    get articles_url

    assert_equal "index", @controller.action_name
    assert_equal "application/x-www-form-urlencoded", @request.media_type
    assert_match "Articles", @response.body
  end
end
```

### 設置標頭和 CGI 變量

可以將[HTTP 標頭](https://tools.ietf.org/search/rfc2616#section-5.3)
和
[CGI 變量](https://tools.ietf.org/search/rfc3875#section-4.1)
作為標頭傳遞：

```ruby
# 設置 HTTP 標頭
get articles_url, headers: { "Content-Type": "text/plain" } # 模擬帶有自定義標頭的請求

# 設置 CGI 變量
get articles_url, headers: { "HTTP_REFERER": "http://example.com/home" } # 模擬帶有自定義環境變量的請求
```

### 測試 `flash` 通知

如果您還記得之前的內容，末日的三個哈希之一是 `flash`。

我們希望在我們的博客應用程序中，每當有人成功創建一篇新文章時，都能添加一個 `flash` 消息。

讓我們首先將這個斷言添加到我們的 `test_should_create_article` 測試中：

```ruby
test "should create article" do
  assert_difference("Article.count") do
    post articles_url, params: { article: { title: "Some title" } }
  end

  assert_redirected_to article_path(Article.last)
  assert_equal "Article was successfully created.", flash[:notice]
end
```

如果我們現在運行測試，應該會看到一個失敗：

```bash
$ bin/rails test test/controllers/articles_controller_test.rb -n test_should_create_article
Run options: -n test_should_create_article --seed 32266

# Running:

F

Finished in 0.114870s, 8.7055 runs/s, 34.8220 assertions/s.

  1) Failure:
ArticlesControllerTest#test_should_create_article [/test/controllers/articles_controller_test.rb:16]:
--- expected
+++ actual
@@ -1 +1 @@
-"Article was successfully created."
+nil

1 runs, 4 assertions, 1 failures, 0 errors, 0 skips
```

現在讓我們在控制器中實現這個 `flash` 消息。我們的 `:create` 操作應該如下所示：

```ruby
def create
  @article = Article.new(article_params)

  if @article.save
    flash[:notice] = "Article was successfully created."
    redirect_to @article
  else
    render "new"
  end
end
```

現在，如果我們運行測試，應該會看到它通過：

```bash
$ bin/rails test test/controllers/articles_controller_test.rb -n test_should_create_article
Run options: -n test_should_create_article --seed 18981

# Running:

.

Finished in 0.081972s, 12.1993 runs/s, 48.7972 assertions/s.

1 runs, 4 assertions, 0 failures, 0 errors, 0 skips
```

### 把它放在一起

到目前為止，我們的 Articles 控制器測試了 `:index`、`:new` 和 `:create` 操作。那麼處理現有數據呢？

讓我們為 `:show` 操作編寫一個測試：

```ruby
test "should show article" do
  article = articles(:one)
  get article_url(article)
  assert_response :success
end
```

從之前關於固定數據的討論中，我們知道 `articles()` 方法將使我們能夠訪問我們的 Articles 固定數據。

那麼刪除一篇現有的文章呢？

```ruby
test "should destroy article" do
  article = articles(:one)
  assert_difference("Article.count", -1) do
    delete article_url(article)
  end

  assert_redirected_to articles_path
end
```

我們還可以添加一個測試來更新一篇現有的文章。

```ruby
test "should update article" do
  article = articles(:one)

  patch article_url(article), params: { article: { title: "updated" } }

  assert_redirected_to article_path(article)
  # 重新加載關聯以獲取更新的數據並斷言標題已更新。
  article.reload
  assert_equal "updated", article.title
end
```

請注意，這三個測試中開始出現了一些重複，它們都訪問相同的 Article 固定數據。我們可以通過使用 `ActiveSupport::Callbacks` 提供的 `setup` 和 `teardown` 方法來消除這種重複。

現在，我們的測試應該如下所示。暫時忽略其他測試，為了簡潔起見，我們將它們省略了。
```ruby
require "test_helper"

class ArticlesControllerTest < ActionDispatch::IntegrationTest
  # 在每個測試之前調用
  setup do
    @article = articles(:one)
  end

  # 在每個測試之後調用
  teardown do
    # 當控制器使用緩存時，重置緩存可能是一個好主意
    Rails.cache.clear
  end

  test "應該顯示文章" do
    # 重用 setup 中的 @article 實例變量
    get article_url(@article)
    assert_response :success
  end

  test "應該刪除文章" do
    assert_difference("Article.count", -1) do
      delete article_url(@article)
    end

    assert_redirected_to articles_path
  end

  test "應該更新文章" do
    patch article_url(@article), params: { article: { title: "updated" } }

    assert_redirected_to article_path(@article)
    # 重新加載關聯以獲取更新的數據並斷言標題已更新
    @article.reload
    assert_equal "updated", @article.title
  end
end
```

與 Rails 中的其他回調類似，`setup` 和 `teardown` 方法也可以通過傳遞塊、lambda 或方法名作為符號來使用。

### 測試助手

為了避免代碼重複，您可以添加自己的測試助手。
登錄助手可以作為一個很好的例子：

```ruby
# test/test_helper.rb

module SignInHelper
  def sign_in_as(user)
    post sign_in_url(email: user.email, password: user.password)
  end
end

class ActionDispatch::IntegrationTest
  include SignInHelper
end
```

```ruby
require "test_helper"

class ProfileControllerTest < ActionDispatch::IntegrationTest
  test "應該顯示個人資料" do
    # 現在助手可以在任何控制器測試案例中重複使用
    sign_in_as users(:david)

    get profile_url
    assert_response :success
  end
end
```

#### 使用單獨的文件

如果您發現助手在 `test_helper.rb` 中雜亂無章，您可以將它們提取到單獨的文件中。
一個好的存儲位置是 `test/lib` 或 `test/test_helpers`。

```ruby
# test/test_helpers/multiple_assertions.rb
module MultipleAssertions
  def assert_multiple_of_forty_two(number)
    assert (number % 42 == 0), "expected #{number} to be a multiple of 42"
  end
end
```

然後可以根據需要顯式地要求這些助手並包含它們

```ruby
require "test_helper"
require "test_helpers/multiple_assertions"

class NumberTest < ActiveSupport::TestCase
  include MultipleAssertions

  test "420 是 42 的倍數" do
    assert_multiple_of_forty_two 420
  end
end
```

或者它們可以繼續直接包含到相關的父類中

```ruby
# test/test_helper.rb
require "test_helpers/sign_in_helper"

class ActionDispatch::IntegrationTest
  include SignInHelper
end
```

#### 預先要求助手

您可能會發現在 `test_helper.rb` 中急於要求助手，以便您的測試文件可以隱式地訪問它們。這可以通過使用 globbing 來實現，如下所示

```ruby
# test/test_helper.rb
Dir[Rails.root.join("test", "test_helpers", "**", "*.rb")].each { |file| require file }
```

這樣做的缺點是增加了啟動時間，而不是在個別測試中僅手動要求必要的文件。

測試路由
--------------

與 Rails 中的其他一切一樣，您可以測試您的路由。路由測試位於 `test/controllers/` 中，或者是控制器測試的一部分。

注意：如果您的應用程序具有複雜的路由，Rails 提供了許多有用的助手來測試它們。

有關 Rails 中可用的路由斷言的更多信息，請參閱 [`ActionDispatch::Assertions::RoutingAssertions`](https://api.rubyonrails.org/classes/ActionDispatch/Assertions/RoutingAssertions.html) 的 API 文檔。

測試視圖
-------------

通過斷言關鍵 HTML 元素及其內容的存在來測試對請求的響應是測試應用程序視圖的常見方法。與路由測試一樣，視圖測試位於 `test/controllers/` 中，或者是控制器測試的一部分。`assert_select` 方法允許您使用簡單而強大的語法查詢響應的 HTML 元素。

`assert_select` 有兩種形式：

`assert_select(selector, [equality], [message])` 通過選擇器確保所選元素上的等式條件得到滿足。選擇器可以是 CSS 選擇器表達式（字符串）或帶有替換值的表達式。

`assert_select(element, selector, [equality], [message])` 通過選擇器從 _element_（`Nokogiri::XML::Node` 或 `Nokogiri::XML::NodeSet` 的實例）及其後代開始，確保所選元素上的等式條件得到滿足。

例如，您可以使用以下代碼驗證響應中標題元素的內容：

```ruby
assert_select "title", "歡迎來到 Rails 測試指南"
```

您還可以使用嵌套的 `assert_select` 塊進行更深入的調查。

在下面的示例中，內部的 `assert_select` 用於 `li.menu_item`，它在外部塊選擇的元素集合中運行：

```ruby
assert_select "ul.navigation" do
  assert_select "li.menu_item"
end
```

所選元素的集合可以遍歷，以便可以為每個元素單獨調用 `assert_select`。

例如，如果響應包含兩個有四個嵌套列表元素的有序列表，則以下測試都將通過。

```ruby
assert_select "ol" do |elements|
  elements.each do |element|
    assert_select element, "li", 4
  end
end

assert_select "ol" do
  assert_select "li", 8
end
```

這個斷言非常強大。有關更高級的用法，請參閱其[文檔](https://github.com/rails/rails-dom-testing/blob/master/lib/rails/dom/testing/assertions/selector_assertions.rb)。

### 額外的基於視圖的斷言

還有一些主要用於測試視圖的斷言：

| 斷言                                                 | 目的 |
| --------------------------------------------------------- | ------- |
| `assert_select_email`                                     | 允許你對電子郵件的主體進行斷言。 |
| `assert_select_encoded`                                   | 允許你對編碼的HTML進行斷言。它通過對每個元素的內容進行解碼，然後調用帶有所有未編碼元素的塊。|
| `css_select(selector)` 或 `css_select(element, selector)` | 返回由_selector_選擇的所有元素的數組。在第二種變體中，它首先匹配基本_element_，然後嘗試在其任何子元素上匹配_selector_表達式。如果沒有匹配，兩種變體都返回一個空數組。|

這是使用`assert_select_email`的示例：

```ruby
assert_select_email do
  assert_select "small", "Please click the 'Unsubscribe' link if you want to opt-out."
end
```

測試幫助程序
---------------

幫助程序只是一個簡單的模塊，您可以在其中定義在視圖中可用的方法。

為了測試幫助程序，您只需要檢查幫助程序方法的輸出是否與您期望的相符。與幫助程序相關的測試位於`test/helpers`目錄下。

假設我們有以下幫助程序：

```ruby
module UsersHelper
  def link_to_user(user)
    link_to "#{user.first_name} #{user.last_name}", user
  end
end
```

我們可以像這樣測試此方法的輸出：

```ruby
class UsersHelperTest < ActionView::TestCase
  test "should return the user's full name" do
    user = users(:david)

    assert_dom_equal %{<a href="/user/#{user.id}">David Heinemeier Hansson</a>}, link_to_user(user)
  end
end
```

此外，由於測試類擴展自`ActionView::TestCase`，您可以訪問Rails的幫助程序方法，例如`link_to`或`pluralize`。

測試您的郵件發送器
--------------------

測試郵件發送器類需要一些特定的工具來進行徹底的工作。

### 監控郵差

您的郵件發送器類 - 像Rails應用程序的其他部分一樣 - 應該經過測試，以確保它們按預期工作。

測試郵件發送器類的目標是確保：

* 郵件正在被處理（創建和發送）
* 郵件內容正確（主題、發件人、正文等）
* 正確的郵件在正確的時間發送

#### 從各個方面

測試郵件發送器有兩個方面，單元測試和功能測試。在單元測試中，您以緊密控制的輸入獨立運行郵件發送器，並將輸出與已知值（夾具）進行比較。在功能測試中，您不太關注郵件發送器產生的細節；相反，我們測試我們的控制器和模型是否正確使用郵件發送器。您測試以證明在正確的時間發送了正確的郵件。

### 單元測試

為了測試您的郵件發送器是否按預期工作，您可以使用單元測試將郵件發送器的實際結果與預先編寫的示例進行比較。

#### 夾具的復仇

為了單元測試郵件發送器，夾具用於提供輸出應該看起來像的示例。因為這些是示例郵件，而不是像其他夾具一樣的Active Record數據，它們被保存在與其他夾具分開的自己的子目錄中。`test/fixtures`目錄中的目錄名直接對應於郵件發送器的名稱。因此，對於名為`UserMailer`的郵件發送器，夾具應該位於`test/fixtures/user_mailer`目錄中。

如果生成了郵件發送器，生成器不會為郵件發送器的操作創建存根夾具。您需要根據上述描述自己創建這些文件。

#### 基本測試用例

這是一個單元測試，用於測試名為`UserMailer`的郵件發送器，其`invite`操作用於向朋友發送邀請。這是根據為`invite`操作生成器創建的基本測試的改編版本。

```ruby
require "test_helper"

class UserMailerTest < ActionMailer::TestCase
  test "invite" do
    # 創建郵件並將其存儲以進行進一步的斷言
    email = UserMailer.create_invite("me@example.com",
                                     "friend@example.com", Time.now)

    # 發送郵件，然後測試它是否被排隊
    assert_emails 1 do
      email.deliver_now
    end

    # 測試發送的郵件正文是否包含我們期望的內容
    assert_equal ["me@example.com"], email.from
    assert_equal ["friend@example.com"], email.to
    assert_equal "You have been invited by me@example.com", email.subject
    assert_equal read_fixture("invite").join, email.body.to_s
  end
end
```
在測試中，我們創建了郵件並將返回的對象存儲在`email`變量中。然後，我們確保它已經發送（第一個斷言），然後在第二批斷言中，我們確保郵件確實包含我們期望的內容。輔助函數`read_fixture`用於從文件中讀取內容。

注意：當只有一個（HTML或文本）部分存在時，`email.body.to_s`存在。如果郵件提供了兩者，您可以使用`email.text_part.body.to_s`或`email.html_part.body.to_s`來測試您的fixture。

這是`invite` fixture的內容：

```
Hi friend@example.com,

You have been invited.

Cheers!
```

現在是時候更深入地了解如何為您的郵件編寫測試了。在`config/environments/test.rb`中的`ActionMailer::Base.delivery_method = :test`行將交付方法設置為測試模式，因此郵件實際上不會被發送（在測試期間避免向用戶發送垃圾郵件），而是會附加到一個數組（`ActionMailer::Base.deliveries`）中。

注意：`ActionMailer::Base.deliveries`數組僅在`ActionMailer::TestCase`和`ActionDispatch::IntegrationTest`測試中自動重置。如果您想在這些測試案例之外擁有一個乾淨的開始，可以使用`ActionMailer::Base.deliveries.clear`手動重置它。

#### 測試已排隊的郵件

您可以使用`assert_enqueued_email_with`斷言來確認郵件已經排隊，並且具有所有預期的郵件方法參數和/或參數化的郵件參數。這允許您匹配使用`deliver_later`方法排隊的任何郵件。

與基本測試案例一樣，我們創建了郵件並將返回的對象存儲在`email`變量中。以下示例包括傳遞參數和/或參數的變化。

此示例將斷言郵件已使用正確的參數排隊：

```ruby
require "test_helper"

class UserMailerTest < ActionMailer::TestCase
  test "invite" do
    # 創建郵件並將其存儲以進行進一步的斷言
    email = UserMailer.create_invite("me@example.com", "friend@example.com")

    # 測試郵件是否已使用正確的參數排隊
    assert_enqueued_email_with UserMailer, :create_invite, args: ["me@example.com", "friend@example.com"] do
      email.deliver_later
    end
  end
end
```

此示例將斷言郵件已使用正確的郵件方法命名參數排隊，通過將參數的哈希作為`args`傳遞：

```ruby
require "test_helper"

class UserMailerTest < ActionMailer::TestCase
  test "invite" do
    # 創建郵件並將其存儲以進行進一步的斷言
    email = UserMailer.create_invite(from: "me@example.com", to: "friend@example.com")

    # 測試郵件是否已使用正確的命名參數排隊
    assert_enqueued_email_with UserMailer, :create_invite, args: [{ from: "me@example.com",
                                                                    to: "friend@example.com" }] do
      email.deliver_later
    end
  end
end
```

此示例將斷言已使用正確的參數和參數排隊的參數化郵件排隊。郵件參數作為`params`傳遞，郵件方法參數作為`args`傳遞：

```ruby
require "test_helper"

class UserMailerTest < ActionMailer::TestCase
  test "invite" do
    # 創建郵件並將其存儲以進行進一步的斷言
    email = UserMailer.with(all: "good").create_invite("me@example.com", "friend@example.com")

    # 測試郵件是否已使用正確的郵件參數和參數排隊
    assert_enqueued_email_with UserMailer, :create_invite, params: { all: "good" },
                                                           args: ["me@example.com", "friend@example.com"] do
      email.deliver_later
    end
  end
end
```

此示例展示了測試已使用正確參數排隊的參數化郵件的另一種方法：

```ruby
require "test_helper"

class UserMailerTest < ActionMailer::TestCase
  test "invite" do
    # 創建郵件並將其存儲以進行進一步的斷言
    email = UserMailer.with(to: "friend@example.com").create_invite

    # 測試郵件是否已使用正確的郵件參數排隊
    assert_enqueued_email_with UserMailer.with(to: "friend@example.com"), :create_invite do
      email.deliver_later
    end
  end
end
```

### 功能測試和系統測試

單元測試允許我們測試郵件的屬性，而功能測試和系統測試允許我們測試用戶交互是否適當地觸發郵件的發送。例如，您可以檢查邀請朋友操作是否正確地發送郵件：

```ruby
# 整合測試
require "test_helper"

class UsersControllerTest < ActionDispatch::IntegrationTest
  test "invite friend" do
    # 斷言 ActionMailer::Base.deliveries 的差異
    assert_emails 1 do
      post invite_friend_url, params: { email: "friend@example.com" }
    end
  end
end
```

```ruby
# 系統測試
require "test_helper"

class UsersTest < ActionDispatch::SystemTestCase
  driven_by :selenium, using: :headless_chrome

  test "inviting a friend" do
    visit invite_users_url
    fill_in "Email", with: "friend@example.com"
    assert_emails 1 do
      click_on "Invite"
    end
  end
end
```

注意：`assert_emails`方法不與特定的交付方法綁定，並且可以與使用`deliver_now`或`deliver_later`方法交付的郵件一起使用。如果我們明確地想要斷言郵件已經排隊，我們可以使用`assert_enqueued_email_with`（[上面的示例](#testing-enqueued-emails)）或`assert_enqueued_emails`方法。更多信息可以在[此處的文檔中](https://api.rubyonrails.org/classes/ActionMailer/TestHelper.html)找到。
測試工作
------------

由於您的自定義工作可以在應用程序中的不同層級上排隊，因此您需要測試工作本身（它們在排隊時的行為）以及其他實體是否正確地將它們排隊。

### 基本測試案例

默認情況下，當您生成一個工作時，相應的測試也會生成在`test/jobs`目錄下。這是一個帶有計費工作的示例測試：

```ruby
require "test_helper"

class BillingJobTest < ActiveJob::TestCase
  test "帳戶被扣款" do
    BillingJob.perform_now(account, product)
    assert account.reload.charged_for?(product)
  end
end
```

這個測試非常簡單，只斷言工作是否按預期工作。

### 自定義斷言和在其他組件中測試工作

Active Job附帶了一系列自定義斷言，可用於測試時減少冗長程度。有關可用斷言的完整列表，請參閱[`ActiveJob::TestHelper`](https://api.rubyonrails.org/classes/ActiveJob/TestHelper.html)的API文檔。

確保在調用工作的地方（例如在控制器內部）正確地將工作排隊或執行是一種良好的實踐。這正是Active Job提供的自定義斷言非常有用的地方。例如，在模型內部，您可以確認工作是否已排隊：

```ruby
require "test_helper"

class ProductTest < ActiveSupport::TestCase
  include ActiveJob::TestHelper

  test "計費工作排程" do
    assert_enqueued_with(job: BillingJob) do
      product.charge(account)
    end
    assert_not account.reload.charged_for?(product)
  end
end
```

默認的適配器`：test`在排隊時不執行工作。您必須告訴它何時要執行工作：

```ruby
require "test_helper"

class ProductTest < ActiveSupport::TestCase
  include ActiveJob::TestHelper

  test "計費工作排程" do
    perform_enqueued_jobs(only: BillingJob) do
      product.charge(account)
    end
    assert account.reload.charged_for?(product)
  end
end
```

在任何測試運行之前，所有先前執行和排隊的工作都會被清除，因此您可以安全地假設在每個測試範圍內尚未執行任何工作。

測試Action Cable
--------------------

由於Action Cable在應用程序的不同層級上使用，因此您需要測試通道、連接類本身以及其他實體是否廣播正確的消息。

### 連接測試案例

默認情況下，當您使用Action Cable生成新的Rails應用程序時，基本連接類（`ApplicationCable::Connection`）的測試也會生成在`test/channels/application_cable`目錄下。

連接測試旨在檢查連接的標識是否被正確分配，或者是否拒絕任何不正確的連接請求。這是一個示例：

```ruby
class ApplicationCable::ConnectionTest < ActionCable::Connection::TestCase
  test "帶參數連接" do
    # 通過調用`connect`方法來模擬連接打開
    connect params: { user_id: 42 }

    # 您可以通過測試中的`connection`訪問Connection對象
    assert_equal connection.user_id, "42"
  end

  test "拒絕不帶參數的連接" do
    # 使用`assert_reject_connection`匹配器來驗證連接是否被拒絕
    assert_reject_connection { connect }
  end
end
```

您也可以像在集成測試中一樣指定請求cookie：

```ruby
test "帶cookie連接" do
  cookies.signed[:user_id] = "42"

  connect

  assert_equal connection.user_id, "42"
end
```

有關更多信息，請參閱[`ActionCable::Connection::TestCase`](https://api.rubyonrails.org/classes/ActionCable/Connection/TestCase.html)的API文檔。

### 通道測試案例

默認情況下，當您生成一個通道時，相應的測試也會生成在`test/channels`目錄下。這是一個帶有聊天通道的示例測試：

```ruby
require "test_helper"

class ChatChannelTest < ActionCable::Channel::TestCase
  test "訂閱並為房間流" do
    # 通過調用`subscribe`來模擬訂閱創建
    subscribe room: "15"

    # 您可以通過測試中的`subscription`訪問Channel對象
    assert subscription.confirmed?
    assert_has_stream "chat_15"
  end
end
```

這個測試非常簡單，只斷言通道將連接訂閱到特定的流。

您還可以指定底層連接標識。這是一個帶有Web通知通道的示例測試：

```ruby
require "test_helper"

class WebNotificationsChannelTest < ActionCable::Channel::TestCase
  test "訂閱並為用戶流" do
    stub_connection current_user: users(:john)

    subscribe

    assert_has_stream_for users(:john)
  end
end
```

有關更多信息，請參閱[`ActionCable::Channel::TestCase`](https://api.rubyonrails.org/classes/ActionCable/Channel/TestCase.html)的API文檔。

### 自定義斷言和在其他組件中測試廣播

Action Cable附帶了一系列自定義斷言，可用於測試時減少冗長程度。有關可用斷言的完整列表，請參閱[`ActionCable::TestHelper`](https://api.rubyonrails.org/classes/ActionCable/TestHelper.html)的API文檔。

確保正確的消息已在其他組件（例如在控制器內部）廣播是一種良好的實踐。這正是Action Cable提供的自定義斷言非常有用的地方。例如，在模型內部：
```ruby
require "test_helper"

class ProductTest < ActionCable::TestCase
  test "充值後廣播狀態" do
    assert_broadcast_on("products:#{product.id}", type: "charged") do
      product.charge(account)
    end
  end
end
```

如果你想測試使用 `Channel.broadcast_to` 進行的廣播，你應該使用 `Channel.broadcasting_for` 來生成底層的流名稱：

```ruby
# app/jobs/chat_relay_job.rb
class ChatRelayJob < ApplicationJob
  def perform(room, message)
    ChatChannel.broadcast_to room, text: message
  end
end
```

```ruby
# test/jobs/chat_relay_job_test.rb
require "test_helper"

class ChatRelayJobTest < ActiveJob::TestCase
  include ActionCable::TestHelper

  test "廣播訊息到房間" do
    room = rooms(:all)

    assert_broadcast_on(ChatChannel.broadcasting_for(room), text: "Hi!") do
      ChatRelayJob.perform_now(room, "Hi!")
    end
  end
end
```

測試 Eager Loading
---------------------

通常，應用程式在 `development` 或 `test` 環境中不會使用 eager load 以加快速度。但在 `production` 環境中會使用。

如果專案中的某些檔案由於某種原因無法載入，你最好在部署到 production 之前檢測到它，對吧？

### 持續整合

如果你的專案有持續整合，則在 CI 中使用 eager load 是確保應用程式 eager load 的簡單方法。

CI 通常會設置某些環境變數來指示測試套件正在運行。例如，可以是 `CI`：

```ruby
# config/environments/test.rb
config.eager_load = ENV["CI"].present?
```

從 Rails 7 開始，新生成的應用程式預設配置為這樣。

### 單獨的測試套件

如果你的專案沒有持續整合，你仍然可以在測試套件中使用 eager load，只需調用 `Rails.application.eager_load!`：

#### Minitest

```ruby
require "test_helper"

class ZeitwerkComplianceTest < ActiveSupport::TestCase
  test "eager load 所有檔案並無錯誤" do
    assert_nothing_raised { Rails.application.eager_load! }
  end
end
```

#### RSpec

```ruby
require "rails_helper"

RSpec.describe "Zeitwerk compliance" do
  it "eager load 所有檔案並無錯誤" do
    expect { Rails.application.eager_load! }.not_to raise_error
  end
end
```

其他測試資源
----------------------------

### 測試與時間相關的程式碼

Rails 提供了內建的輔助方法，使您能夠斷言您的時間相關程式碼按預期工作。

以下示例使用 [`travel_to`][travel_to] 輔助方法：

```ruby
# 假設使用者在註冊後一個月才有資格贈送。
user = User.create(name: "Gaurish", activation_date: Date.new(2004, 10, 24))
assert_not user.applicable_for_gifting?

travel_to Date.new(2004, 11, 24) do
  # 在 `travel_to` 區塊內，`Date.current` 被 stub
  assert_equal Date.new(2004, 10, 24), user.activation_date
  assert user.applicable_for_gifting?
end

# 這個變化只在 `travel_to` 區塊內可見。
assert_equal Date.new(2004, 10, 24), user.activation_date
```

請參閱 [`ActiveSupport::Testing::TimeHelpers`][time_helpers_api] API 參考以獲取有關可用時間輔助方法的更多資訊。
[`config.active_support.test_order`]: configuring.html#config-active-support-test-order
[image/png]: https://developer.mozilla.org/en-US/docs/Web/HTTP/Basics_of_HTTP/MIME_types#image_types
[travel_to]: https://api.rubyonrails.org/classes/ActiveSupport/Testing/TimeHelpers.html#method-i-travel_to
[time_helpers_api]: https://api.rubyonrails.org/classes/ActiveSupport/Testing/TimeHelpers.html
