**DO NOT READ THIS FILE ON GITHUB, GUIDES ARE PUBLISHED ON https://guides.rubyonrails.org.**, original file md5: 58b6e6f83da0f420f5da5f7d38d938db
API 文件撰寫指南
================

本指南記錄了 Ruby on Rails API 文件撰寫的指南。

閱讀完本指南後，您將了解：

* 如何撰寫有效的文件敘述。
* 撰寫不同種類 Ruby 代碼的風格指南。

--------------------------------------------------------------------------------

RDoc
----

[Rails API 文件](https://api.rubyonrails.org) 是使用 [RDoc](https://ruby.github.io/rdoc/) 生成的。要生成它，請確保您在 Rails 根目錄下，執行 `bundle install`，然後執行：

```bash
$ bundle exec rake rdoc
```

生成的 HTML 文件可以在 ./doc/rdoc 目錄中找到。

注意：請參考 RDoc [標記參考][RDoc 標記] 以獲得語法幫助。

連結
----

Rails API 文件不適合在 GitHub 上查看，因此連結應使用 RDoc 的 [`link`][RDoc 連結] 標記相對於當前 API。

這是因為 GitHub Markdown 和在 [api.rubyonrails.org](https://api.rubyonrails.org) 和 [edgeapi.rubyonrails.org](https://edgeapi.rubyonrails.org) 上發佈的生成的 RDoc 之間存在差異。

例如，我們使用 `[link:classes/ActiveRecord/Base.html]` 來創建一個連結到 RDoc 生成的 `ActiveRecord::Base` 類。

這比使用絕對 URL，如 `[https://api.rubyonrails.org/classes/ActiveRecord/Base.html]` 更好，後者會將讀者帶出他們當前的文件版本（例如 edgeapi.rubyonrails.org）。

[RDoc 標記]: https://ruby.github.io/rdoc/RDoc/MarkupReference.html
[RDoc 連結]: https://ruby.github.io/rdoc/RDoc/MarkupReference.html#class-RDoc::MarkupReference-label-Links

用詞
----

使用簡單、陳述性的句子。簡潔明瞭是一個優點：直接點明要點。

使用現在時態：「返回一個哈希...」，而不是「返回了一個哈希...」或「將返回一個哈希...」。

以大寫字母開頭的註釋。遵循常規標點符號規則：

```ruby
# 声明由內部命名的實例變量支持的屬性讀取器。
def attr_internal_reader(*attrs)
  # ...
end
```

向讀者傳達當前的做事方式，無論是明確還是隱含。使用 edge 推薦的慣用語法。如果需要，重新排序部分以強調優選方法等。文件應該是最佳實踐和規範的模範，符合現代 Rails 用法。

文件必須簡潔但全面。探索並記錄邊界情況。如果模塊是匿名的會發生什麼？如果集合為空會發生什麼？如果參數為 nil 會發生什麼？

Rails 組件的正確名稱單詞之間有一個空格，例如 "Active Support"。`ActiveRecord` 是一個 Ruby 模塊，而 Active Record 是一個 ORM。所有 Rails 文件應一致地使用正確的名稱來引用 Rails 組件。

當提及「Rails 應用程序」時，與「引擎」或「插件」相對，請始終使用「應用程序」。Rails 應用程序不是「服務」，除非特別討論服務導向架構。

正確拼寫名稱：Arel、minitest、RSpec、HTML、MySQL、JavaScript、ERB、Hotwire。如果不確定，請查看一些權威來源，如官方文件。

在用詞上，請避免使用「你」和「你的」。例如，不要使用以下風格：

```markdown
如果您需要在回調中使用 `return` 語句，建議明確定義它們作為方法。
```

使用以下風格：

```markdown
如果需要使用 `return`，建議明確定義一個方法。
```

話雖如此，當在參考虛構人物時使用代詞，例如「帶有會話 cookie 的用戶」，應使用性別中立的代詞（they/their/them）。而不是：

* 他或她... 使用 they。
* 他或她... 使用 them。
* 他或她的... 使用 their。
* 他或她的... 使用 theirs。
* 他自己或她自己... 使用 themselves。

英語
----

請使用美式英語（*color*、*center*、*modularize* 等）。請參閱[此處的美式和英式英語拼寫差異列表](https://en.wikipedia.org/wiki/American_and_British_English_spelling_differences)。

牛津逗號
--------

請使用[牛津逗號](https://en.wikipedia.org/wiki/Serial_comma)（例如 "red, white, and blue"，而不是 "red, white and blue"）。

示例代碼
--------

選擇有意義的示例，涵蓋基礎知識以及有趣的點或陷阱。

使用兩個空格縮進代碼塊，即對於標記目的，相對於左邊邊緣，使用兩個空格。示例本身應使用 [Rails 編碼慣例](contributing_to_ruby_on_rails.html#follow-the-coding-conventions)。

簡短的文檔不需要明確的「示例」標籤來介紹片段；它們只是跟在段落後面：

```ruby
# 通過調用 +to_s+ 並將所有元素連接起來，將元素集合轉換為格式化字符串。
#
#   Blog.all.to_fs # => "First PostSecond PostThird Post"
```

另一方面，結構化文檔的大塊可能有一個單獨的「示例」部分：

```ruby
# ==== 示例
#
#   Person.exists?(5)
#   Person.exists?('5')
#   Person.exists?(name: "David")
#   Person.exists?(['name LIKE ?', "%#{query}%"])
```
表達式的結果跟隨在它們後面，並以“# =>”引入，垂直對齊：

```ruby
# 用於檢查整數是偶數還是奇數。
#
#   1.even? # => false
#   1.odd?  # => true
#   2.even? # => true
#   2.odd?  # => false
```

如果一行太長，註釋可以放在下一行：

```ruby
#   label(:article, :title)
#   # => <label for="article_title">Title</label>
#
#   label(:article, :title, "A short title")
#   # => <label for="article_title">A short title</label>
#
#   label(:article, :title, "A short title", class: "title_label")
#   # => <label for="article_title" class="title_label">A short title</label>
```

請避免使用任何像`puts`或`p`這樣的打印方法。

另一方面，常規註釋不使用箭頭：

```ruby
#   polymorphic_url(record)  # same as comment_url(record)
```

### SQL

在記錄SQL語句時，輸出之前不應該有`=>`。

例如，

```ruby
#   User.where(name: 'Oscar').to_sql
#   # SELECT "users".* FROM "users"  WHERE "users"."name" = 'Oscar'
```

### IRB

在記錄IRB的行為時，Ruby的交互式REPL，始終以`irb>`為前綴，輸出應以`=>`為前綴。

例如，

```
# 查找主鍵（id）為10的客戶。
#   irb> customer = Customer.find(10)
#   # => #<Customer id: 10, first_name: "Ryan">
```

### Bash / 命令行

對於命令行示例，始終以`$`為前綴，輸出不需要以任何前綴。

```
# 執行以下命令：
#   $ bin/rails new zomg
#   ...
```

布爾值
--------

在謂詞和標誌中，優先使用布爾語義而不是確切值進行文檔記錄。

當"true"或"false"在Ruby中使用時，使用常規字體。單例`true`和`false`需要使用固定寬度字體。請避免使用"truthy"等術語，Ruby在語言中定義了什麼是真和假，因此這些詞具有技術含義，不需要替代詞。

作為一個經驗法則，除非絕對必要，否則不要記錄單例。這樣可以避免人為構造，如`!!`或三元運算符，允許重構，並且代碼不需要依賴於在實現中調用的方法返回的確切值。

例如：

```markdown
`config.action_mailer.perform_deliveries`指定郵件是否實際傳遞，默認情況下為true
```

用戶不需要知道標誌的實際默認值，因此我們只記錄其布爾語義。

帶有謂詞的示例：

```ruby
# 如果集合為空，則返回true。
#
# 如果集合已加載，則等效於<tt>collection.size.zero?</tt>。如果
# 集合未加載，則等效於<tt>!collection.exists?</tt>。如果集合尚未
# 加載，並且您打算在任何情況下提取記錄，最好檢查<tt>collection.length.zero?</tt>。
def empty?
  if loaded?
    size.zero?
  else
    @target.blank? && !scope.exists?
  end
end
```

API小心不要承諾任何特定的值，該方法具有謂詞語義，這已足夠。

文件名
----------

作為一個經驗法則，使用相對於應用程序根目錄的文件名：

```
config/routes.rb            # 是
routes.rb                   # 否
RAILS_ROOT/config/routes.rb # 否
```

字體
-----

### 固定寬度字體

使用固定寬度字體：

* 常量，特別是類和模塊名稱。
* 方法名。
* 字面常量，如`nil`，`false`，`true`，`self`。
* 符號。
* 方法參數。
* 文件名。

```ruby
class Array
  # 對所有元素調用+to_param+，並使用斜杠連接結果。這在Action Pack的+url_for+中使用。
  def to_param
    collect { |e| e.to_param }.join '/'
  end
end
```

警告：僅對固定內容（如普通類、模塊、方法名、符號、帶有斜杠的路徑等）使用`+...+`固定寬度字體。請對其他內容使用`<tt>...</tt>`形式。

您可以使用以下命令快速測試RDoc輸出：

```bash
$ echo "+:to_param+" | rdoc --pipe
# => <p><code>:to_param</code></p>
```

例如，帶有空格或引號的代碼應使用`<tt>...</tt>`形式。

### 常規字體

當"true"和"false"是英文單詞而不是Ruby關鍵字時，使用常規字體：

```ruby
# 在指定的上下文中運行所有驗證。
# 如果未找到錯誤，則返回true；否則返回false。
#
# 如果參數為false（默認為+nil+），則如果<tt>new_record?</tt>為true，上下文設置為<tt>:create</tt>；
# 如果<tt>new_record?</tt>不為true，則設置為<tt>:update</tt>。
#
# 沒有<tt>:on</tt>選項的驗證將在任何上下文中運行。具有# 一些<tt>:on</tt>選項的驗證將僅在指定的上下文中運行。
def valid?(context = nil)
  # ...
end
```
描述清單
-----------------

在選項、參數等清單中，使用連字符將項目和其描述分隔（比冒號更易讀，因為通常選項是符號）：

```ruby
# * <tt>:allow_nil</tt> - 如果屬性為 +nil+，則跳過驗證。
```

描述以大寫字母開始，以句號結束，這是標準的英文寫法。

另一種方法是使用選項區段樣式，以提供更多細節和示例。

[`ActiveSupport::MessageEncryptor#encrypt_and_sign`][#encrypt_and_sign] 是一個很好的例子。

```ruby
# ==== 選項
#
# [+:expires_at+]
#   訊息過期的日期時間。在此日期時間之後，對訊息的驗證將失敗。
#
#     message = encryptor.encrypt_and_sign("hello", expires_at: Time.now.tomorrow)
#     encryptor.decrypt_and_verify(message) # => "hello"
#     # 24小時後...
#     encryptor.decrypt_and_verify(message) # => nil
```


動態生成的方法
-----------------------------

使用 `(module|class)_eval(STRING)` 創建的方法旁邊有一個帶有生成代碼示例的註釋。該註釋與模板相距2個空格：

[![(module|class)_eval(STRING) code comments](images/dynamic_method_class_eval.png)](images/dynamic_method_class_eval.png)

如果生成的行過寬，例如200個字符或更多，將註釋放在調用上方：

```ruby
# def self.find_by_login_and_activated(*args)
#   options = args.extract_options!
#   ...
# end
self.class_eval %{
  def self.#{method_id}(*args)
    options = args.extract_options!
    ...
  end
}, __FILE__, __LINE__
```

方法的可見性
-----------------

在為Rails撰寫文檔時，了解公共用戶界面API與內部API之間的區別非常重要。

Rails和大多數庫一樣，使用Ruby的private關鍵字來定義內部API。然而，公共API遵循稍微不同的約定。Rails使用 `:nodoc:` 指令將這些類型的方法標記為內部API，而不是假設所有公共方法都是為用戶使用而設計的。

這意味著Rails中存在具有 `public` 可見性的方法，但這些方法並不適用於用戶使用。

一個例子是 `ActiveRecord::Core::ClassMethods#arel_table`：

```ruby
module ActiveRecord::Core::ClassMethods
  def arel_table # :nodoc:
    # 做一些魔法..
  end
end
```

如果你認為 "這個方法看起來像是 `ActiveRecord::Core` 的公共類方法"，你是對的。但實際上，Rails團隊不希望用戶依賴於此方法。因此，他們將其標記為 `:nodoc:`，並從公共文檔中刪除。這樣做的原因是允許團隊根據他們在不同版本中的內部需求自由更改這些方法。這個方法的名稱可能會改變，或者返回值可能會改變，或者整個類可能會消失；沒有保證，因此你不應該依賴於你的插件或應用程序中的此API。否則，當你升級到新版本的Rails時，你的應用程序或gem可能會出現問題。

作為貢獻者，重要的是要考慮此API是否適用於最終用戶使用。Rails團隊承諾在不經過完整的棄用週期的情況下不對公共API進行任何破壞性更改。建議你將你的內部方法/類中的任何內部方法/類都標記為 `:nodoc:`，除非它們已經是私有的（即可見性），在這種情況下，默認情況下它們是內部的。一旦API穩定下來，可見性可以改變，但由於向後兼容性的原因，更改公共API要困難得多。

使用 `:nodoc:` 標記類或模塊，以指示所有方法都是內部API，不應直接使用。

總結一下，Rails團隊使用 `:nodoc:` 標記公開可見的方法和類，用於內部使用；對API可見性的更改應該仔細考慮，並在拉取請求中進行討論。

關於Rails堆棧
-------------------------

在記錄Rails API的部分時，記住Rails堆棧中的所有組件是很重要的。

這意味著行為可能會根據您要記錄的方法或類的範圍或上下文而改變。

在各個地方，考慮到整個堆棧，行為可能會有所不同，其中一個例子是 `ActionView::Helpers::AssetTagHelper#image_tag`：

```ruby
# image_tag("icon.png")
#   # => <img src="/assets/icon.png" />
```

雖然 `#image_tag` 的默認行為始終是返回 `/images/icon.png`，但是考慮到完整的Rails堆棧（包括資源管道），我們可能會看到上面的結果。

我們只關心在使用完整默認Rails堆棧時的行為。

在這種情況下，我們希望記錄框架的行為，而不僅僅是這個特定方法的行為。

如果對於Rails團隊如何處理某些API有疑問，請隨時在[問題跟踪器](https://github.com/rails/rails/issues)上開啟一個問題或提交一個補丁。
[#encrypt_and_sign]: https://edgeapi.rubyonrails.org/classes/ActiveSupport/MessageEncryptor.html#method-i-encrypt_and_sign
