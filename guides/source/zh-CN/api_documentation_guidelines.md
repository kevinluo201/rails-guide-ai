**DO NOT READ THIS FILE ON GITHUB, GUIDES ARE PUBLISHED ON https://guides.rubyonrails.org.**, original file md5: 58b6e6f83da0f420f5da5f7d38d938db
API文档指南
============================

本指南记录了Ruby on Rails API文档的指南。

阅读本指南后，您将了解：

* 如何为文档目的编写有效的散文。
* 用于记录不同类型的Ruby代码的样式指南。

--------------------------------------------------------------------------------

RDoc
----

[Rails API文档](https://api.rubyonrails.org)是使用[RDoc](https://ruby.github.io/rdoc/)生成的。要生成它，请确保您在rails根目录中，运行`bundle install`并执行：

```bash
$ bundle exec rake rdoc
```

生成的HTML文件可以在./doc/rdoc目录中找到。

注意：请参考RDoc [标记参考][RDoc标记]以获取语法帮助。

链接
-----

Rails API文档不适合在GitHub上查看，因此链接应使用相对于当前API的RDoc [`link`][RDoc链接]标记。 

这是由于GitHub Markdown和发布在[api.rubyonrails.org](https://api.rubyonrails.org)和[edgeapi.rubyonrails.org](https://edgeapi.rubyonrails.org)上的生成的RDoc之间的差异。

例如，我们使用`[link:classes/ActiveRecord/Base.html]`来创建一个链接到RDoc生成的`ActiveRecord::Base`类的链接。

这比使用绝对URL更好，例如`[https://api.rubyonrails.org/classes/ActiveRecord/Base.html]`，这将使读者离开他们当前的文档版本（例如edgeapi.rubyonrails.org）。

[RDoc标记]: https://ruby.github.io/rdoc/RDoc/MarkupReference.html
[RDoc链接]: https://ruby.github.io/rdoc/RDoc/MarkupReference.html#class-RDoc::MarkupReference-label-Links

措辞
-------

使用简单、陈述性的句子。简洁性是一个优点：言简意赅。

使用现在时态：例如“返回一个哈希...”，而不是“返回了一个哈希...”或“将返回一个哈希...”。

以大写字母开头的注释。遵循常规的标点规则：

```ruby
# 声明由内部命名的实例变量支持的属性读取器。
def attr_internal_reader(*attrs)
  # ...
end
```

向读者传达当前的做事方式，无论是明确还是隐含。使用edge推荐的习语。如果需要，重新排序部分以强调首选方法等。文档应该是最佳实践和规范的现代Rails用法的模型。

文档必须简洁但全面。探索和记录边界情况。如果模块是匿名的会发生什么？如果集合为空会发生什么？如果参数为nil会发生什么？

Rails组件的正确名称单词之间有一个空格，例如"Active Support"。`ActiveRecord`是一个Ruby模块，而Active Record是一个ORM。所有Rails文档应一致地使用正确的名称来引用Rails组件。

在引用“Rails应用程序”时，与“引擎”或“插件”相对应，始终使用“应用程序”。Rails应用程序不是“服务”，除非特别讨论面向服务的架构。

正确拼写名称：Arel，minitest，RSpec，HTML，MySQL，JavaScript，ERB，Hotwire。如果有疑问，请查看它们的官方文档等权威来源。

使用“an”来表示“SQL”，例如“an SQL statement”。还有“an SQLite database”。

更喜欢避免使用“you”和“your”的措辞。例如，不要使用以下样式：

```markdown
如果您需要在回调中使用`return`语句，建议您将其明确定义为方法。
```

使用这种样式：

```markdown
如果需要使用`return`，建议明确定义一个方法。
```

也就是说，当在参考一个假设的人时使用代词，例如“具有会话cookie的用户”，应该使用中性的代词（they/their/them）。而不是：

* 他或她...使用they。
* 他或她...使用them。
* 他或她的...使用their。
* 他或她的...使用theirs。
* 他自己或她自己...使用themselves。

英语
-------

请使用美式英语（*color*，*center*，*modularize*等）。请参阅[这里的美式和英式英语拼写差异列表](https://en.wikipedia.org/wiki/American_and_British_English_spelling_differences)。

牛津逗号
------------

请使用[牛津逗号](https://en.wikipedia.org/wiki/Serial_comma)
（"red, white, and blue"，而不是"red, white and blue"）。

示例代码
------------

选择有意义的示例，描绘和涵盖基础知识以及有趣的要点或陷阱。

使用两个空格缩进代码块 - 也就是说，对于标记目的，相对于左边缘，使用两个空格。示例本身应使用[Rails编码约定](contributing_to_ruby_on_rails.html#follow-the-coding-conventions)。

简短的文档不需要显式的“Examples”标签来介绍片段；它们只是跟随段落：

```ruby
# 通过调用+to_s+并将所有元素连接起来，将元素集合转换为格式化字符串。
#
#   Blog.all.to_fs # => "First PostSecond PostThird Post"
```

另一方面，大块结构化文档可能有一个单独的“Examples”部分：

```ruby
# ==== Examples
#
#   Person.exists?(5)
#   Person.exists?('5')
#   Person.exists?(name: "David")
#   Person.exists?(['name LIKE ?', "%#{query}%"])
```
表达式的结果跟随其后，并以“# =>”进行介绍，垂直对齐：

```ruby
# 用于检查整数是偶数还是奇数。
#
#   1.even? # => false
#   1.odd?  # => true
#   2.even? # => true
#   2.odd?  # => false
```

如果一行太长，注释可以放在下一行：

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

避免使用`puts`或`p`等打印方法。

另一方面，常规注释不使用箭头：

```ruby
#   polymorphic_url(record)  # 与comment_url(record)相同
```

### SQL

在记录SQL语句时，输出之前不应有`=>`。

例如，

```ruby
#   User.where(name: 'Oscar').to_sql
#   # SELECT "users".* FROM "users"  WHERE "users"."name" = 'Oscar'
```

### IRB

在记录IRB（Ruby的交互式REPL）的行为时，始终以`irb>`为前缀，并且输出应以`=>`为前缀。

例如，

```
# 查找主键（id）为10的客户。
#   irb> customer = Customer.find(10)
#   # => #<Customer id: 10, first_name: "Ryan">
```

### Bash / 命令行

对于命令行示例，始终以`$`为前缀，输出不需要以任何内容为前缀。

```
# 运行以下命令：
#   $ bin/rails new zomg
#   ...
```

布尔值
--------

在谓词和标志中，优先记录布尔语义而不是确切的值。

当"true"或"false"在Ruby中定义时，使用常规字体。单例`true`和`false`需要使用等宽字体。请避免使用"truthy"等术语，Ruby在语言中定义了什么是真和假，因此这些词具有技术含义，不需要替代词。

作为经验法则，除非绝对必要，否则不要记录单例。这样可以避免人为构造的结构，如`!!`或三元运算符，允许重构，并且代码不需要依赖于在实现中调用的方法返回的确切值。

例如：

```markdown
`config.action_mailer.perform_deliveries`指定邮件是否实际发送，默认为true
```

用户不需要知道标志的实际默认值，因此我们只记录其布尔语义。

带有谓词的示例：

```ruby
# 如果集合为空，则返回true。
#
# 如果集合已加载，则等同于<tt>collection.size.zero?</tt>。如果
# 集合尚未加载，则等同于<tt>!collection.exists?</tt>。如果集合尚未
# 加载，并且您将要获取记录，则最好检查<tt>collection.length.zero?</tt>。
def empty?
  if loaded?
    size.zero?
  else
    @target.blank? && !scope.exists?
  end
end
```

API小心地不承诺任何特定的值，该方法具有谓词语义，这已经足够了。

文件名
----------

作为经验法则，使用相对于应用程序根目录的文件名：

```
config/routes.rb            # 是
routes.rb                   # 否
RAILS_ROOT/config/routes.rb # 否
```

字体
-----

### 等宽字体

对于以下内容，请使用等宽字体：

* 常量，特别是类和模块名称。
* 方法名。
* 字面量，如`nil`，`false`，`true`，`self`。
* 符号。
* 方法参数。
* 文件名。

```ruby
class Array
  # 对其所有元素调用+to_param+，并使用斜杠连接结果。这由Action Pack中的+url_for+使用。
  def to_param
    collect { |e| e.to_param }.join '/'
  end
end
```

警告：仅对简单内容（如普通类、模块、方法名、符号、路径（带正斜杠）等）使用`+...+`以获得等宽字体。其他内容应使用`<tt>...</tt>`形式。

您可以使用以下命令快速测试RDoc输出：

```bash
$ echo "+:to_param+" | rdoc --pipe
# => <p><code>:to_param</code></p>
```

例如，带有空格或引号的代码应使用`<tt>...</tt>`形式。

### 常规字体

当"true"和"false"是英文单词而不是Ruby关键字时，请使用常规字体：

```ruby
# 在指定的上下文中运行所有验证。
# 如果未发现错误，则返回true；否则返回false。
#
# 如果参数为false（默认为+nil+），则如果<tt>new_record?</tt>为true，则上下文设置为<tt>:create</tt>；
# 如果<tt>new_record?</tt>不为true，则上下文设置为<tt>:update</tt>。
#
# 没有<tt>:on</tt>选项的验证将在任何上下文中运行。
# 一些<tt>:on</tt>选项的验证将仅在指定的上下文中运行。
def valid?(context = nil)
  # ...
end
```
描述列表
-----------------

在选项、参数等列表中，使用连字符将项目和其描述分开（读起来比冒号更好，因为通常选项是符号）：

```ruby
# * <tt>:allow_nil</tt> - 如果属性为+nil+，则跳过验证。
```

描述以大写字母开头，以句号结尾——这是标准英语。

另一种方法是使用选项部分样式，以提供额外的细节和示例。

[`ActiveSupport::MessageEncryptor#encrypt_and_sign`][#encrypt_and_sign] 是一个很好的例子。

```ruby
# ==== 选项
#
# [+:expires_at+]
#   消息过期的日期时间。在此日期时间之后，消息的验证将失败。
#
#     message = encryptor.encrypt_and_sign("hello", expires_at: Time.now.tomorrow)
#     encryptor.decrypt_and_verify(message) # => "hello"
#     # 24小时后...
#     encryptor.decrypt_and_verify(message) # => nil
```


动态生成的方法
-----------------------------

使用`(module|class)_eval(STRING)`创建的方法旁边有一个带有生成代码示例的注释。该注释与模板相隔2个空格：

[![(module|class)_eval(STRING) 代码注释](images/dynamic_method_class_eval.png)](images/dynamic_method_class_eval.png)

如果生成的行太宽，比如200列或更多，请将注释放在调用上方：

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

方法可见性
-----------------

在编写Rails文档时，理解公共用户界面API与内部API之间的区别非常重要。

Rails与大多数库一样，使用Ruby的private关键字来定义内部API。然而，公共API遵循稍微不同的约定。Rails使用`:nodoc:`指令来注释这些类型的方法作为内部API，而不是假设所有公共方法都是为用户使用而设计的。

这意味着Rails中有一些具有`public`可见性的方法并不适用于用户使用。

一个例子是`ActiveRecord::Core::ClassMethods#arel_table`：

```ruby
module ActiveRecord::Core::ClassMethods
  def arel_table # :nodoc:
    # 做一些魔法..
  end
end
```

如果你认为“这个方法看起来像是`ActiveRecord::Core`的公共类方法”，那么你是对的。但实际上，Rails团队不希望用户依赖这个方法。所以他们将其标记为`:nodoc:`，并从公共文档中删除。这样做的原因是允许团队根据他们在不同版本中的内部需求自由更改这些方法。这个方法的名称可能会改变，或者返回值可能会改变，或者整个类可能会消失；没有任何保证，因此你不应该在你的插件或应用程序中依赖这个API。否则，当你升级到新版本的Rails时，你的应用程序或gem可能会出现问题。

作为贡献者，重要的是要考虑这个API是否适用于最终用户使用。Rails团队承诺在不经过完整弃用周期的情况下不对公共API进行任何破坏性更改。建议你对任何内部方法/类使用`:nodoc:`，除非它们已经是私有的（即可见性），在这种情况下，默认情况下是内部的。一旦API稳定，可见性可以改变，但由于向后兼容性，更改公共API要困难得多。

使用`:nodoc:`标记类或模块，表示所有方法都是内部API，不应直接使用。

总之，Rails团队使用`:nodoc:`来标记公开可见的方法和类作为内部使用；对API可见性的更改应该经过仔细考虑，并在拉取请求中进行讨论。

关于Rails堆栈
-------------------------

在文档化Rails API的部分时，记住Rails堆栈中的所有组件是很重要的。

这意味着行为可能会根据你要文档化的方法或类的范围或上下文而改变。

在考虑整个堆栈时，各个地方的行为可能会有所不同，一个例子是`ActionView::Helpers::AssetTagHelper#image_tag`：

```ruby
# image_tag("icon.png")
#   # => <img src="/assets/icon.png" />
```

虽然`#image_tag`的默认行为始终是返回`/images/icon.png`，但是当考虑到完整的Rails堆栈（包括Asset Pipeline）时，我们可能会看到上面的结果。

我们只关心在使用完整默认Rails堆栈时的行为。

在这种情况下，我们希望文档化的是_framework_的行为，而不仅仅是这个特定方法的行为。

如果你对Rails团队如何处理某些API有疑问，请随时在[问题跟踪器](https://github.com/rails/rails/issues)上开启一个工单或发送一个补丁。
[#encrypt_and_sign]: https://edgeapi.rubyonrails.org/classes/ActiveSupport/MessageEncryptor.html#method-i-encrypt_and_sign
