**DO NOT READ THIS FILE ON GITHUB, GUIDES ARE PUBLISHED ON https://guides.rubyonrails.org.**, original file md5: fdd2e5c41171c61b555549ced4d68a82
Active Support核心扩展
==============================

Active Support是Ruby on Rails组件，负责提供Ruby语言的扩展和实用工具。

它在语言层面上提供了更丰富的功能，既适用于开发Rails应用程序，也适用于开发Ruby on Rails本身。

阅读本指南后，您将了解：

* 什么是核心扩展。
* 如何加载所有扩展。
* 如何选择您想要的扩展。
* Active Support提供了哪些扩展。

--------------------------------------------------------------------------------

如何加载核心扩展
---------------------------

### 独立的Active Support

为了尽可能减小默认占用空间，Active Support默认加载最少的依赖项。它被分成小块，以便只加载所需的扩展。它还提供了一些方便的入口点，可以一次性加载相关的扩展，甚至是全部扩展。

因此，只需简单的require：

```ruby
require "active_support"
```

只会加载Active Support框架所需的扩展。

#### 选择性加载定义

以下示例展示了如何加载[`Hash#with_indifferent_access`][Hash#with_indifferent_access]。该扩展允许将`Hash`转换为[`ActiveSupport::HashWithIndifferentAccess`][ActiveSupport::HashWithIndifferentAccess]，从而可以使用字符串或符号访问键。

```ruby
{ a: 1 }.with_indifferent_access["a"] # => 1
```

对于每个定义为核心扩展的方法，本指南都有一个说明，说明该方法定义在哪里。对于`with_indifferent_access`，说明如下：

注意：定义在`active_support/core_ext/hash/indifferent_access.rb`中。

这意味着您可以这样require它：

```ruby
require "active_support"
require "active_support/core_ext/hash/indifferent_access"
```

Active Support经过精心修订，因此选择性加载文件只会加载严格需要的依赖项（如果有的话）。

#### 加载分组的核心扩展

下一级是简单地加载所有`Hash`的扩展。一般来说，`SomeClass`的扩展可以通过加载`active_support/core_ext/some_class`一次性获得。

因此，要加载所有`Hash`的扩展（包括`with_indifferent_access`）：

```ruby
require "active_support"
require "active_support/core_ext/hash"
```

#### 加载所有核心扩展

您可能只想加载所有核心扩展，有一个文件可以做到：

```ruby
require "active_support"
require "active_support/core_ext"
```

#### 加载所有Active Support

最后，如果您想要加载所有Active Support，只需执行以下操作：

```ruby
require "active_support/all"
```

实际上，这甚至不会将整个Active Support全部加载到内存中，一些内容是通过`autoload`进行配置的，因此只有在使用时才会加载。

### 在Ruby on Rails应用程序中使用Active Support

Ruby on Rails应用程序会加载所有Active Support，除非[`config.active_support.bare`][]为true。在这种情况下，应用程序只会加载框架自身为自己的需求选择的内容，并且仍然可以根据需要在任何粒度级别进行选择，如前一节所述。


所有对象的扩展
-------------------------

### `blank?`和`present?`

在Rails应用程序中，以下值被视为空值：

* `nil`和`false`，

* 仅由空格组成的字符串（见下面的说明），

* 空数组和哈希，以及

* 其他任何响应`empty?`并且为空的对象。

信息：字符串的谓词使用支持Unicode的字符类`[:space:]`，因此例如U+2029（段落分隔符）被视为空格。

警告：请注意，数字没有被提及。特别是，0和0.0**不是**空的。

例如，`ActionController::HttpAuthentication::Token::ControllerMethods`中的此方法使用[`blank?`][Object#blank?]来检查令牌是否存在：

```ruby
def authenticate(controller, &login_procedure)
  token, options = token_and_options(controller.request)
  unless token.blank?
    login_procedure.call(token, options)
  end
end
```

方法[`present?`][Object#present?]等同于`!blank?`。以下示例来自`ActionDispatch::Http::Cache::Response`：

```ruby
def set_conditional_cache_control!
  return if self["Cache-Control"].present?
  # ...
end
```

注意：定义在`active_support/core_ext/object/blank.rb`中。


### `presence`

[`presence`][Object#presence]方法如果`present?`则返回接收者，否则返回`nil`。它对于像这样的习语非常有用：
```ruby
host = config[:host].presence || 'localhost'
```

注意：定义在`active_support/core_ext/object/blank.rb`中。


### `duplicable?`

从Ruby 2.5开始，大多数对象都可以通过`dup`或`clone`进行复制：

```ruby
"foo".dup           # => "foo"
"".dup              # => ""
Rational(1).dup     # => (1/1)
Complex(0).dup      # => (0+0i)
1.method(:+).dup    # => TypeError (Method没有定义分配器)
```

Active Support提供了[`duplicable?`][Object#duplicable?]来查询对象是否可以复制：

```ruby
"foo".duplicable?           # => true
"".duplicable?              # => true
Rational(1).duplicable?     # => true
Complex(1).duplicable?      # => true
1.method(:+).duplicable?    # => false
```

警告：任何类都可以通过删除`dup`和`clone`或从中引发异常来禁止复制。因此，只有`rescue`可以判断给定的任意对象是否可复制。`duplicable?`依赖于上面的硬编码列表，但它比`rescue`要快得多。只有在您知道硬编码列表在您的用例中足够时才使用它。

注意：定义在`active_support/core_ext/object/duplicable.rb`中。


### `deep_dup`

[`deep_dup`][Object#deep_dup]方法返回给定对象的深拷贝。通常，当您对包含其他对象的对象进行`dup`时，Ruby不会对它们进行`dup`，因此它创建了对象的浅拷贝。例如，如果您有一个包含字符串的数组，它将如下所示：

```ruby
array     = ['string']
duplicate = array.dup

duplicate.push 'another-string'

# 对象已复制，因此元素仅添加到副本中
array     # => ['string']
duplicate # => ['string', 'another-string']

duplicate.first.gsub!('string', 'foo')

# 第一个元素没有复制，它将在两个数组中都被更改
array     # => ['foo']
duplicate # => ['foo', 'another-string']
```

如您所见，在复制`Array`实例之后，我们得到了另一个对象，因此我们可以修改它，而原始对象将保持不变。但是，对于数组的元素来说，情况并非如此。由于`dup`不进行深拷贝，因此数组中的字符串仍然是同一个对象。

如果您需要对象的深拷贝，应使用`deep_dup`。这是一个例子：

```ruby
array     = ['string']
duplicate = array.deep_dup

duplicate.first.gsub!('string', 'foo')

array     # => ['string']
duplicate # => ['foo']
```

如果对象不可复制，`deep_dup`将返回它本身：

```ruby
number = 1
duplicate = number.deep_dup
number.object_id == duplicate.object_id   # => true
```

注意：定义在`active_support/core_ext/object/deep_dup.rb`中。


### `try`

当您只想在对象不为`nil`时调用方法时，最简单的方法是使用条件语句，但会增加不必要的混乱。另一种选择是使用[`try`][Object#try]。`try`类似于`Object#public_send`，但如果发送给`nil`，它会返回`nil`。

这是一个例子：

```ruby
# 不使用try
unless @number.nil?
  @number.next
end

# 使用try
@number.try(:next)
```

另一个例子是来自`ActiveRecord::ConnectionAdapters::AbstractAdapter`的代码，其中`@logger`可能为`nil`。您可以看到代码使用了`try`，避免了不必要的检查。

```ruby
def log_info(sql, name, ms)
  if @logger.try(:debug?)
    name = '%s (%.1fms)' % [name || 'SQL', ms]
    @logger.debug(format_log_entry(name, sql.squeeze(' ')))
  end
end
```

`try`还可以在没有参数但有一个块的情况下调用，只有在对象不为nil时才会执行该块：

```ruby
@person.try { |p| "#{p.first_name} #{p.last_name}" }
```

请注意，`try`将吞掉无方法错误，返回`nil`。如果要防止拼写错误，请改用[`try!`][Object#try!]：

```ruby
@number.try(:nest)  # => nil
@number.try!(:nest) # NoMethodError: undefined method `nest' for 1:Integer
```

注意：定义在`active_support/core_ext/object/try.rb`中。


### `class_eval(*args, &block)`

您可以使用[`class_eval`][Kernel#class_eval]在任何对象的单例类上下文中评估代码：

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

注意：定义在`active_support/core_ext/kernel/singleton_class.rb`中。


### `acts_like?(duck)`

方法[`acts_like?`][Object#acts_like?]提供了一种检查某个类是否像另一个类一样的方法，基于一个简单的约定：提供与`String`相同接口的类定义了一个`acts_like?`方法。
```ruby
def acts_like_string?
end
```

这只是一个标记，它的主体或返回值都是无关紧要的。然后，客户端代码可以通过以下方式查询鸭子类型的安全性：

```ruby
some_klass.acts_like?(:string)
```

Rails有一些类似于`Date`或`Time`的类，并遵循这个约定。

注意：定义在`active_support/core_ext/object/acts_like.rb`中。


### `to_param`

Rails中的所有对象都响应方法[`to_param`][Object#to_param]，该方法用于返回表示它们作为查询字符串或URL片段的值的内容。

默认情况下，`to_param`只是调用`to_s`：

```ruby
7.to_param # => "7"
```

`to_param`的返回值**不应该**被转义：

```ruby
"Tom & Jerry".to_param # => "Tom & Jerry"
```

Rails中的几个类重写了这个方法。

例如，`nil`，`true`和`false`返回它们自己。[`Array#to_param`][Array#to_param]调用元素的`to_param`并使用“/”连接结果：

```ruby
[0, true, String].to_param # => "0/true/String"
```

值得注意的是，Rails路由系统调用模型的`to_param`来获取`：id`占位符的值。`ActiveRecord::Base#to_param`返回模型的`id`，但您可以在模型中重新定义该方法。例如，给定

```ruby
class User
  def to_param
    "#{id}-#{name.parameterize}"
  end
end
```

我们得到：

```ruby
user_path(@user) # => "/users/357-john-smith"
```

警告：控制器需要注意`to_param`的任何重新定义，因为当像这样的请求进来时，“357-john-smith”是`params[:id]`的值。

注意：定义在`active_support/core_ext/object/to_param.rb`中。


### `to_query`

[`to_query`][Object#to_query]方法构造一个查询字符串，将给定的`key`与`to_param`的返回值关联起来。例如，使用以下`to_param`定义：

```ruby
class User
  def to_param
    "#{id}-#{name.parameterize}"
  end
end
```

我们得到：

```ruby
current_user.to_query('user') # => "user=357-john-smith"
```

该方法会对所需的内容进行转义，包括键和值：

```ruby
account.to_query('company[name]')
# => "company%5Bname%5D=Johnson+%26+Johnson"
```

因此，它的输出已经准备好在查询字符串中使用。

数组返回将`key[]`作为键应用`to_query`到每个元素的结果，并使用“&”连接结果：

```ruby
[3.4, -45.6].to_query('sample')
# => "sample%5B%5D=3.4&sample%5B%5D=-45.6"
```

哈希也响应`to_query`，但具有不同的签名。如果没有传递参数，调用会生成一个按键进行排序的键/值分配的系列，调用其值的`to_query(key)`。然后，它使用“&”连接结果：

```ruby
{ c: 3, b: 2, a: 1 }.to_query # => "a=1&b=2&c=3"
```

方法[`Hash#to_query`][Hash#to_query]接受可选的命名空间作为键：

```ruby
{ id: 89, name: "John Smith" }.to_query('user')
# => "user%5Bid%5D=89&user%5Bname%5D=John+Smith"
```

注意：定义在`active_support/core_ext/object/to_query.rb`中。


### `with_options`

方法[`with_options`][Object#with_options]提供了一种在一系列方法调用中提取公共选项的方式。

给定一个默认选项哈希，`with_options`会将一个代理对象传递给块。在块内，对代理调用的方法将被转发到接收者，并合并其选项。例如，你可以通过以下方式消除重复：

```ruby
class Account < ApplicationRecord
  has_many :customers, dependent: :destroy
  has_many :products,  dependent: :destroy
  has_many :invoices,  dependent: :destroy
  has_many :expenses,  dependent: :destroy
end
```

这样做：

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

这种习惯用法也可以传达给读者“分组”的概念。例如，假设您想要发送一封新闻通讯，其语言取决于用户。在邮件程序的某个地方，您可以像这样分组与语言相关的部分：

```ruby
I18n.with_options locale: user.locale, scope: "newsletter" do |i18n|
  subject i18n.t :subject
  body    i18n.t :body, user_name: user.name
end
```

提示：由于`with_options`将调用转发到其接收者，它们可以嵌套。每个嵌套级别都将合并继承的默认值以及它们自己的默认值。

注意：定义在`active_support/core_ext/object/with_options.rb`中。


### JSON支持

Active Support提供了比`json` gem在Ruby对象上通常提供的更好的`to_json`实现。这是因为某些类，如`Hash`和`Process::Status`，需要特殊处理才能提供正确的JSON表示。
注意：在`active_support/core_ext/object/json.rb`中定义。

### 实例变量

Active Support提供了几种方法来简化对实例变量的访问。

#### `instance_values`

方法[`instance_values`][Object#instance_values]返回一个将没有"@"符号的实例变量名映射到其对应值的哈希表。键是字符串：

```ruby
class C
  def initialize(x, y)
    @x, @y = x, y
  end
end

C.new(0, 1).instance_values # => {"x" => 0, "y" => 1}
```

注意：在`active_support/core_ext/object/instance_variables.rb`中定义。


#### `instance_variable_names`

方法[`instance_variable_names`][Object#instance_variable_names]返回一个数组。每个名称都包含"@"符号。

```ruby
class C
  def initialize(x, y)
    @x, @y = x, y
  end
end

C.new(0, 1).instance_variable_names # => ["@x", "@y"]
```

注意：在`active_support/core_ext/object/instance_variables.rb`中定义。


### 消除警告和异常

方法[`silence_warnings`][Kernel#silence_warnings]和[`enable_warnings`][Kernel#enable_warnings]根据其块的持续时间更改`$VERBOSE`的值，并在之后重置它：

```ruby
silence_warnings { Object.const_set "RAILS_DEFAULT_LOGGER", logger }
```

使用[`suppress`][Kernel#suppress]也可以消除异常。该方法接收任意数量的异常类。如果在块的执行过程中引发了一个异常，并且该异常是参数中的任何一个的`kind_of?`，`suppress`会捕获它并返回静默。否则，异常不会被捕获：

```ruby
# 如果用户被锁定，增量将丢失，没关系。
suppress(ActiveRecord::StaleObjectError) do
  current_user.increment! :visits
end
```

注意：在`active_support/core_ext/kernel/reporting.rb`中定义。


### `in?`

谓词[`in?`][Object#in?]测试一个对象是否包含在另一个对象中。如果传递的参数不响应`include?`，将引发`ArgumentError`异常。

`in?`的示例：

```ruby
1.in?([1, 2])        # => true
"lo".in?("hello")   # => true
25.in?(30..50)      # => false
1.in?(1)            # => ArgumentError
```

注意：在`active_support/core_ext/object/inclusion.rb`中定义。


`Module`的扩展
----------------------

### 属性

#### `alias_attribute`

模型属性具有读取器、写入器和谓词。您可以使用[`alias_attribute`][Module#alias_attribute]为模型属性创建别名，这样对应的三个方法都会为您定义。与其他别名方法一样，新名称是第一个参数，旧名称是第二个参数（一个助记符是它们按照赋值的顺序排列）：

```ruby
class User < ApplicationRecord
  # 您可以将email列称为"login"。
  # 这对于身份验证代码可能是有意义的。
  alias_attribute :login, :email
end
```

注意：在`active_support/core_ext/module/aliasing.rb`中定义。


#### 内部属性

当您在一个预期被子类化的类中定义属性时，名称冲突是一个风险。这对于库来说非常重要。

Active Support定义了宏[`attr_internal_reader`][Module#attr_internal_reader]、[`attr_internal_writer`][Module#attr_internal_writer]和[`attr_internal_accessor`][Module#attr_internal_accessor]。它们的行为类似于Ruby内置的`attr_*`对应方法，只是它们以一种使冲突的可能性较小的方式命名底层实例变量。

宏[`attr_internal`][Module#attr_internal]是`attr_internal_accessor`的同义词：

```ruby
# library
class ThirdPartyLibrary::Crawler
  attr_internal :log_level
end

# client code
class MyCrawler < ThirdPartyLibrary::Crawler
  attr_accessor :log_level
end
```

在上面的示例中，`:log_level`可能不属于库的公共接口，只用于开发。客户端代码不知道潜在的冲突，子类化并定义了自己的`:log_level`。由于`attr_internal`的存在，不会发生冲突。

默认情况下，内部实例变量以下划线开头，例如上面的示例中的`@_log_level`。通过`Module.attr_internal_naming_format`可以进行配置，您可以传递任何带有前导`@`和某处的`%s`的`sprintf`格式字符串，其中将放置名称。默认值为`"@_%s"`。

Rails在一些地方使用内部属性，例如视图：

```ruby
module ActionView
  class Base
    attr_internal :captures
    attr_internal :request, :layout
    attr_internal :controller, :template
  end
end
```

注意：在`active_support/core_ext/module/attr_internal.rb`中定义。


#### 模块属性

宏[`mattr_reader`][Module#mattr_reader]、[`mattr_writer`][Module#mattr_writer]和[`mattr_accessor`][Module#mattr_accessor]与为类定义的`cattr_*`宏相同。实际上，`cattr_*`宏只是`mattr_*`宏的别名。请参阅[类属性](#类属性)。
例如，Active Storage的日志记录器的API是使用`mattr_accessor`生成的：

```ruby
module ActiveStorage
  mattr_accessor :logger
end
```

注意：定义在`active_support/core_ext/module/attribute_accessors.rb`中。


### 父模块

#### `module_parent`

嵌套命名模块上的[`module_parent`][Module#module_parent]方法返回包含其对应常量的模块：

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

如果模块是匿名的或属于顶级模块，则`module_parent`返回`Object`。

警告：请注意，在这种情况下，`module_parent_name`返回`nil`。

注意：定义在`active_support/core_ext/module/introspection.rb`中。


#### `module_parent_name`

嵌套命名模块上的[`module_parent_name`][Module#module_parent_name]方法返回包含其对应常量的模块的完全限定名称：

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

对于顶级或匿名模块，`module_parent_name`返回`nil`。

警告：请注意，在这种情况下，`module_parent`返回`Object`。

注意：定义在`active_support/core_ext/module/introspection.rb`中。


#### `module_parents`

[`module_parents`][Module#module_parents]方法在接收器上调用`module_parent`，直到达到`Object`。返回的链以数组形式从底部到顶部返回：

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

注意：定义在`active_support/core_ext/module/introspection.rb`中。


### 匿名模块

一个模块可能有也可能没有名称：

```ruby
module M
end
M.name # => "M"

N = Module.new
N.name # => "N"

Module.new.name # => nil
```

您可以使用谓词[`anonymous?`][Module#anonymous?]检查模块是否具有名称：

```ruby
module M
end
M.anonymous? # => false

Module.new.anonymous? # => true
```

请注意，无法访问并不意味着是匿名的：

```ruby
module M
end

m = Object.send(:remove_const, :M)

m.anonymous? # => false
```

尽管匿名模块在定义上是无法访问的。

注意：定义在`active_support/core_ext/module/anonymous.rb`中。


### 方法委托

#### `delegate`

宏[`delegate`][Module#delegate]提供了一种简单的方法来转发方法。

假设某个应用程序中的用户在`User`模型中具有登录信息，但在单独的`Profile`模型中具有名称和其他数据：

```ruby
class User < ApplicationRecord
  has_one :profile
end
```

通过这种配置，您可以通过用户的配置文件获取用户的名称，`user.profile.name`，但仍然可以直接访问该属性可能会很方便：

```ruby
class User < ApplicationRecord
  has_one :profile

  def name
    profile.name
  end
end
```

这就是`delegate`为您做的事情：

```ruby
class User < ApplicationRecord
  has_one :profile

  delegate :name, to: :profile
end
```

这样更简短，意图更明显。

目标中的方法必须是公共的。

`delegate`宏接受多个方法：

```ruby
delegate :name, :age, :address, :twitter, to: :profile
```

当插入到字符串中时，`:to`选项应该变成一个表达式，该表达式求值为方法委托的对象。通常是一个字符串或符号。这样的表达式在接收器的上下文中求值：

```ruby
# 委托给Rails常量
delegate :logger, to: :Rails

# 委托给接收器的类
delegate :table_name, to: :class
```

警告：如果`：prefix`选项为`true`，则这种方法不太通用，请参见下文。

默认情况下，如果委托引发`NoMethodError`并且目标是`nil`，则会传播异常。您可以使用`：allow_nil`选项要求返回`nil`：

```ruby
delegate :name, to: :profile, allow_nil: true
```

使用`：allow_nil`，如果用户没有配置文件，则调用`user.name`将返回`nil`。

`：prefix`选项在生成的方法的名称前添加前缀。例如，可以使用此选项来获得更好的名称：

```ruby
delegate :street, to: :address, prefix: true
```

上面的示例生成的方法名为`address_street`，而不是`street`。
警告：在这种情况下，生成的方法名称由目标对象和目标方法名称组成，因此 `:to` 选项必须是一个方法名称。

还可以配置自定义前缀：

```ruby
delegate :size, to: :attachment, prefix: :avatar
```

在上面的示例中，宏生成的是 `avatar_size` 而不是 `size`。

选项 `:private` 可以改变方法的作用域：

```ruby
delegate :date_of_birth, to: :profile, private: true
```

委托的方法默认是公开的。传递 `private: true` 来改变这一点。

注意：定义在 `active_support/core_ext/module/delegation.rb` 中


#### `delegate_missing_to`

想象一下，您希望将 `User` 对象上缺失的所有内容委托给 `Profile` 对象。[`delegate_missing_to`][Module#delegate_missing_to] 宏可以让您轻松实现这一点：

```ruby
class User < ApplicationRecord
  has_one :profile

  delegate_missing_to :profile
end
```

目标可以是对象内的任何可调用项，例如实例变量、方法、常量等。只有目标的公共方法会被委托。

注意：定义在 `active_support/core_ext/module/delegation.rb` 中。


### 重新定义方法

有些情况下，您需要使用 `define_method` 定义一个方法，但不知道是否已经存在具有该名称的方法。如果已经存在，如果启用了警告，将会发出警告。这并不是什么大问题，但也不够干净。

方法 [`redefine_method`][Module#redefine_method] 可以防止这种潜在的警告，在需要时删除现有方法。

如果需要自己定义替换方法（例如使用 `delegate`），还可以使用 [`silence_redefinition_of_method`][Module#silence_redefinition_of_method]。

注意：定义在 `active_support/core_ext/module/redefine_method.rb` 中。


`Class` 的扩展
---------------------

### 类属性

#### `class_attribute`

方法 [`class_attribute`][Class#class_attribute] 声明一个或多个可继承的类属性，可以在继承层次结构的任何级别上进行覆盖。

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

例如，`ActionMailer::Base` 定义了：

```ruby
class_attribute :default_params
self.default_params = {
  mime_version: "1.0",
  charset: "UTF-8",
  content_type: "text/plain",
  parts_order: [ "text/plain", "text/enriched", "text/html" ]
}.freeze
```

它们也可以在实例级别进行访问和覆盖。

```ruby
A.x = 1

a1 = A.new
a2 = A.new
a2.x = 2

a1.x # => 1，来自 A
a2.x # => 2，在 a2 中被覆盖
```

通过将选项 `:instance_writer` 设置为 `false`，可以阻止生成写入实例方法。

```ruby
module ActiveRecord
  class Base
    class_attribute :table_name_prefix, instance_writer: false, default: "my"
  end
end
```

模型可能会发现这个选项很有用，作为防止批量赋值设置属性的一种方式。

通过将选项 `:instance_reader` 设置为 `false`，可以阻止生成读取实例方法。

```ruby
class A
  class_attribute :x, instance_reader: false
end

A.new.x = 1
A.new.x # NoMethodError
```

为了方便起见，`class_attribute` 还定义了一个实例谓词，它是实例读取器返回的双重否定。在上面的示例中，它将被称为 `x?`。

当 `:instance_reader` 是 `false` 时，实例谓词返回一个 `NoMethodError`，就像读取方法一样。

如果不想要实例谓词，请传递 `instance_predicate: false`，它将不会被定义。

注意：定义在 `active_support/core_ext/class/attribute.rb` 中。


#### `cattr_reader`、`cattr_writer` 和 `cattr_accessor`

宏 [`cattr_reader`][Module#cattr_reader]、[`cattr_writer`][Module#cattr_writer] 和 [`cattr_accessor`][Module#cattr_accessor] 类似于它们的 `attr_*` 对应物，但用于类。它们将类变量初始化为 `nil`，除非它已经存在，并生成相应的类方法来访问它：

```ruby
class MysqlAdapter < AbstractAdapter
  # 生成访问 @@emulate_booleans 的类方法。
  cattr_accessor :emulate_booleans
end
```

此外，您可以将一个块传递给 `cattr_*`，以使用默认值设置属性：

```ruby
class MysqlAdapter < AbstractAdapter
  # 生成访问 @@emulate_booleans 的类方法，并将默认值设置为 true。
  cattr_accessor :emulate_booleans, default: true
end
```
实例方法也是为了方便而创建的，它们只是类属性的代理。因此，实例可以更改类属性，但不能像`class_attribute`那样覆盖它（参见上文）。例如：

```ruby
module ActionView
  class Base
    cattr_accessor :field_error_proc, default: Proc.new { ... }
  end
end
```

我们可以在视图中访问`field_error_proc`。

可以通过将`:instance_reader`设置为`false`来阻止生成读取实例方法，通过将`:instance_writer`设置为`false`来阻止生成写入实例方法。可以通过将`:instance_accessor`设置为`false`来阻止生成这两个方法。在所有情况下，值必须确切地为`false`，而不是任何假值。

```ruby
module A
  class B
    # 不会生成first_name实例读取器。
    cattr_accessor :first_name, instance_reader: false
    # 不会生成last_name=实例写入器。
    cattr_accessor :last_name, instance_writer: false
    # 不会生成surname实例读取器或surname=写入器。
    cattr_accessor :surname, instance_accessor: false
  end
end
```

模型可能会发现将`:instance_accessor`设置为`false`是一种防止批量赋值设置属性的方法。

注意：定义在`active_support/core_ext/module/attribute_accessors.rb`中。


### 子类和后代

#### `subclasses`

[`subclasses`][Class#subclasses]方法返回接收者的子类：

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

返回这些类的顺序是未指定的。

注意：定义在`active_support/core_ext/class/subclasses.rb`中。


#### `descendants`

[`descendants`][Class#descendants]方法返回所有小于接收者的类：

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

返回这些类的顺序是未指定的。

注意：定义在`active_support/core_ext/class/subclasses.rb`中。


`String`的扩展
----------------------

### 输出安全性

#### 动机

将数据插入HTML模板需要额外的注意。例如，您不能将`@review.title`直接插入HTML页面中。首先，如果评论标题是"Flanagan & Matz rules!"，输出将不符合规范，因为必须将"&"转义为"&amp;amp;"。此外，根据应用程序的不同，这可能是一个严重的安全漏洞，因为用户可以通过设置手工制作的评论标题来注入恶意HTML。有关风险的更多信息，请参阅[安全指南](security.html#cross-site-scripting-xss)中有关跨站脚本攻击的部分。

#### 安全字符串

Active Support引入了_(html) safe_字符串的概念。安全字符串是一种被标记为可以直接插入HTML中的字符串。它是可信的，无论是否已经进行了转义。

默认情况下，字符串被认为是_不安全_的：

```ruby
"".html_safe? # => false
```

您可以使用[`html_safe`][String#html_safe]方法从给定的字符串中获取安全字符串：

```ruby
s = "".html_safe
s.html_safe? # => true
```

重要的是要理解，`html_safe`不执行任何转义，它只是一个断言：

```ruby
s = "<script>...</script>".html_safe
s.html_safe? # => true
s            # => "<script>...</script>"
```

您有责任确保在特定字符串上调用`html_safe`是安全的。

如果您使用`concat`/`<<`或`+`在安全字符串上附加字符串，结果将是安全字符串。不安全的参数将被转义：

```ruby
"".html_safe + "<" # => "&lt;"
```

安全参数将直接附加：

```ruby
"".html_safe + "<".html_safe # => "<"
```

这些方法不应在普通视图中使用。不安全的值将自动转义：

```erb
<%= @review.title %> <%# 如果需要，会被转义 %>
```
要直接插入内容，请使用[`raw`][]助手而不是调用`html_safe`：

```erb
<%= raw @cms.current_template %> <%# 将 @cms.current_template 原样插入 %>
```

或者等效地使用`<%==`：

```erb
<%== @cms.current_template %> <%# 将 @cms.current_template 原样插入 %>
```

`raw`助手会为您调用`html_safe`：

```ruby
def raw(stringish)
  stringish.to_s.html_safe
end
```

注意：定义在`active_support/core_ext/string/output_safety.rb`中。


#### 转换

一般来说，除了可能改变字符串的拼接方法之外，任何可能改变字符串的方法都会返回一个不安全的字符串。这些方法包括`downcase`、`gsub`、`strip`、`chomp`、`underscore`等。

对于像`gsub!`这样的原地转换，接收者本身变得不安全。

信息：无论转换是否实际改变了内容，安全标记总是丢失的。

#### 转换和强制类型转换

在安全字符串上调用`to_s`会返回一个安全字符串，但是使用`to_str`进行强制类型转换会返回一个不安全的字符串。

#### 复制

在安全字符串上调用`dup`或`clone`会产生安全字符串。

### `remove`

方法[`remove`][String#remove]将删除所有匹配的模式：

```ruby
"Hello World".remove(/Hello /) # => "World"
```

还有一个破坏性版本`String#remove!`。

注意：定义在`active_support/core_ext/string/filters.rb`中。


### `squish`

方法[`squish`][String#squish]去除前导和尾随空格，并将连续的空格替换为一个空格：

```ruby
" \n  foo\n\r \t bar \n".squish # => "foo bar"
```

还有一个破坏性版本`String#squish!`。

注意，它处理ASCII和Unicode空格。

注意：定义在`active_support/core_ext/string/filters.rb`中。


### `truncate`

方法[`truncate`][String#truncate]返回截断后的副本，截断长度为给定的`length`：

```ruby
"Oh dear! Oh dear! I shall be late!".truncate(20)
# => "Oh dear! Oh dear!..."
```

省略号可以使用`：omission`选项自定义：

```ruby
"Oh dear! Oh dear! I shall be late!".truncate(20, omission: '&hellip;')
# => "Oh dear! Oh &hellip;"
```

请特别注意，截断会考虑省略字符串的长度。

通过传递`：separator`来在自然断点处截断字符串：

```ruby
"Oh dear! Oh dear! I shall be late!".truncate(18)
# => "Oh dear! Oh dea..."
"Oh dear! Oh dear! I shall be late!".truncate(18, separator: ' ')
# => "Oh dear! Oh..."
```

选项`:separator`可以是正则表达式：

```ruby
"Oh dear! Oh dear! I shall be late!".truncate(18, separator: /\s/)
# => "Oh dear! Oh..."
```

在上面的示例中，"dear"首先被截断，但是`：separator`阻止了截断。

注意：定义在`active_support/core_ext/string/filters.rb`中。


### `truncate_bytes`

方法[`truncate_bytes`][String#truncate_bytes]返回截断后的副本，最多截断到`bytesize`字节：

```ruby
"👍👍👍👍".truncate_bytes(15)
# => "👍👍👍…"
```

省略号可以使用`：omission`选项自定义：

```ruby
"👍👍👍👍".truncate_bytes(15, omission: "🖖")
# => "👍👍🖖"
```

注意：定义在`active_support/core_ext/string/filters.rb`中。


### `truncate_words`

方法[`truncate_words`][String#truncate_words]返回截断后的副本，截断到给定的单词数：

```ruby
"Oh dear! Oh dear! I shall be late!".truncate_words(4)
# => "Oh dear! Oh dear!..."
```

省略号可以使用`：omission`选项自定义：

```ruby
"Oh dear! Oh dear! I shall be late!".truncate_words(4, omission: '&hellip;')
# => "Oh dear! Oh dear!&hellip;"
```

通过传递`：separator`来在自然断点处截断字符串：

```ruby
"Oh dear! Oh dear! I shall be late!".truncate_words(3, separator: '!')
# => "Oh dear! Oh dear! I shall be late..."
```

选项`:separator`可以是正则表达式：

```ruby
"Oh dear! Oh dear! I shall be late!".truncate_words(4, separator: /\s/)
# => "Oh dear! Oh dear!..."
```

注意：定义在`active_support/core_ext/string/filters.rb`中。


### `inquiry`

[`inquiry`][String#inquiry]方法将字符串转换为`StringInquirer`对象，使得相等性检查更加美观。

```ruby
"production".inquiry.production? # => true
"active".inquiry.inactive?       # => false
```

注意：定义在`active_support/core_ext/string/inquiry.rb`中。


### `starts_with?`和`ends_with?`

Active Support定义了`String#start_with?`和`String#end_with?`的第三人称别名：

```ruby
"foo".starts_with?("f") # => true
"foo".ends_with?("o")   # => true
```
注意：在`active_support/core_ext/string/starts_ends_with.rb`中定义。

### `strip_heredoc`

方法[`strip_heredoc`][String#strip_heredoc]用于去除heredocs中的缩进。

例如，在以下代码中：

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

用户将看到对齐在左边边缘的使用消息。

从技术上讲，它会查找整个字符串中缩进最少的行，并删除相应数量的前导空格。

注意：在`active_support/core_ext/string/strip.rb`中定义。


### `indent`

[`indent`][String#indent]方法用于缩进接收者中的行：

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

第二个参数`indent_string`指定要使用的缩进字符串。默认值为`nil`，表示方法会查看第一个缩进的行并进行推测，如果没有缩进的行，则使用空格。

```ruby
"  foo".indent(2)        # => "    foo"
"foo\n\t\tbar".indent(2) # => "\t\tfoo\n\t\t\t\tbar"
"foo".indent(2, "\t")    # => "\t\tfoo"
```

虽然`indent_string`通常是一个空格或制表符，但它可以是任何字符串。

第三个参数`indent_empty_lines`是一个标志，指示是否应缩进空行。默认值为false。

```ruby
"foo\n\nbar".indent(2)            # => "  foo\n\n  bar"
"foo\n\nbar".indent(2, nil, true) # => "  foo\n  \n  bar"
```

[`indent!`][String#indent!]方法在原地执行缩进。

注意：在`active_support/core_ext/string/indent.rb`中定义。


### 访问

#### `at(position)`

[`at`][String#at]方法返回字符串在`position`位置的字符：

```ruby
"hello".at(0)  # => "h"
"hello".at(4)  # => "o"
"hello".at(-1) # => "o"
"hello".at(10) # => nil
```

注意：在`active_support/core_ext/string/access.rb`中定义。


#### `from(position)`

[`from`][String#from]方法返回从`position`位置开始的字符串的子串：

```ruby
"hello".from(0)  # => "hello"
"hello".from(2)  # => "llo"
"hello".from(-2) # => "lo"
"hello".from(10) # => nil
```

注意：在`active_support/core_ext/string/access.rb`中定义。


#### `to(position)`

[`to`][String#to]方法返回字符串到`position`位置的子串：

```ruby
"hello".to(0)  # => "h"
"hello".to(2)  # => "hel"
"hello".to(-2) # => "hell"
"hello".to(10) # => "hello"
```

注意：在`active_support/core_ext/string/access.rb`中定义。


#### `first(limit = 1)`

[`first`][String#first]方法返回包含字符串前`limit`个字符的子串。

调用`str.first(n)`等效于`str.to(n-1)`，如果`n`>0，则返回空字符串`n`==0。

注意：在`active_support/core_ext/string/access.rb`中定义。


#### `last(limit = 1)`

[`last`][String#last]方法返回包含字符串后`limit`个字符的子串。

调用`str.last(n)`等效于`str.from(-n)`，如果`n`>0，则返回空字符串`n`==0。

注意：在`active_support/core_ext/string/access.rb`中定义。


### Inflections

#### `pluralize`

方法[`pluralize`][String#pluralize]返回其接收者的复数形式：

```ruby
"table".pluralize     # => "tables"
"ruby".pluralize      # => "rubies"
"equipment".pluralize # => "equipment"
```

如上例所示，Active Support知道一些不规则的复数形式和不可数名词。内置规则可以在`config/initializers/inflections.rb`中扩展。此文件默认由`rails new`命令生成，并在注释中提供了说明。

`pluralize`还可以接受一个可选的`count`参数。如果`count == 1`，则返回单数形式。对于任何其他值的`count`，将返回复数形式：

```ruby
"dude".pluralize(0) # => "dudes"
"dude".pluralize(1) # => "dude"
"dude".pluralize(2) # => "dudes"
```

Active Record使用此方法计算与模型对应的默认表名：

```ruby
# active_record/model_schema.rb
def undecorated_table_name(model_name)
  table_name = model_name.to_s.demodulize.underscore
  pluralize_table_names ? table_name.pluralize : table_name
end
```

注意：在`active_support/core_ext/string/inflections.rb`中定义。


#### `singularize`

[`singularize`][String#singularize]方法是`pluralize`的反义词：

```ruby
"tables".singularize    # => "table"
"rubies".singularize    # => "ruby"
"equipment".singularize # => "equipment"
```

关联使用此方法来计算对应的默认关联类的名称：

```ruby
# active_record/reflection.rb
def derive_class_name
  class_name = name.to_s.camelize
  class_name = class_name.singularize if collection?
  class_name
end
```
注意：定义在`active_support/core_ext/string/inflections.rb`中。

#### `camelize`

方法[`camelize`][String#camelize]将其接收者转换为驼峰命名法：

```ruby
"product".camelize    # => "Product"
"admin_user".camelize # => "AdminUser"
```

可以将此方法视为将路径转换为Ruby类或模块名称的方法，其中斜杠用于分隔命名空间：

```ruby
"backoffice/session".camelize # => "Backoffice::Session"
```

例如，Action Pack使用此方法加载提供特定会话存储的类：

```ruby
# action_controller/metal/session_management.rb
def session_store=(store)
  @@session_store = store.is_a?(Symbol) ?
    ActionDispatch::Session.const_get(store.to_s.camelize) :
    store
end
```

`camelize`接受一个可选参数，可以是`：upper`（默认）或`：lower`。使用后者，第一个字母将变为小写：

```ruby
"visual_effect".camelize(:lower) # => "visualEffect"
```

在遵循此约定的语言中计算方法名称可能很方便，例如JavaScript。

INFO：可以将`camelize`视为`underscore`的反向操作，但也有一些例外情况：`"SSLError".underscore.camelize`返回`"SslError"`。为了支持这种情况，Active Support允许您在`config/initializers/inflections.rb`中指定首字母缩略词：

```ruby
ActiveSupport::Inflector.inflections do |inflect|
  inflect.acronym 'SSL'
end

"SSLError".underscore.camelize # => "SSLError"
```

`camelize`的别名是[`camelcase`][String#camelcase]。

注意：定义在`active_support/core_ext/string/inflections.rb`中。

#### `underscore`

方法[`underscore`][String#underscore]将驼峰命名法转换为路径：

```ruby
"Product".underscore   # => "product"
"AdminUser".underscore # => "admin_user"
```

还将"::"转换为"/"：

```ruby
"Backoffice::Session".underscore # => "backoffice/session"
```

并且可以理解以小写字母开头的字符串：

```ruby
"visualEffect".underscore # => "visual_effect"
```

`underscore`不接受任何参数。

Rails使用`underscore`获取控制器类的小写名称：

```ruby
# actionpack/lib/abstract_controller/base.rb
def controller_path
  @controller_path ||= name.delete_suffix("Controller").underscore
end
```

例如，该值是在`params[:controller]`中获取的值。

INFO：可以将`underscore`视为`camelize`的反向操作，但也有一些例外情况。例如，`"SSLError".underscore.camelize`返回`"SslError"`。

注意：定义在`active_support/core_ext/string/inflections.rb`中。

#### `titleize`

方法[`titleize`][String#titleize]将接收者中的单词首字母大写：

```ruby
"alice in wonderland".titleize # => "Alice In Wonderland"
"fermat's enigma".titleize     # => "Fermat's Enigma"
```

`titleize`的别名是[`titlecase`][String#titlecase]。

注意：定义在`active_support/core_ext/string/inflections.rb`中。

#### `dasherize`

方法[`dasherize`][String#dasherize]将接收者中的下划线替换为破折号：

```ruby
"name".dasherize         # => "name"
"contact_data".dasherize # => "contact-data"
```

模型的XML序列化器使用此方法将节点名称转换为破折号形式：

```ruby
# active_model/serializers/xml.rb
def reformat_name(name)
  name = name.camelize if camelize?
  dasherize? ? name.dasherize : name
end
```

注意：定义在`active_support/core_ext/string/inflections.rb`中。

#### `demodulize`

给定一个带有限定常量名称的字符串，[`demodulize`][String#demodulize]返回常量名称的最右边部分：

```ruby
"Product".demodulize                        # => "Product"
"Backoffice::UsersController".demodulize    # => "UsersController"
"Admin::Hotel::ReservationUtils".demodulize # => "ReservationUtils"
"::Inflections".demodulize                  # => "Inflections"
"".demodulize                               # => ""
```

例如，Active Record使用此方法计算计数缓存列的名称：

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

注意：定义在`active_support/core_ext/string/inflections.rb`中。

#### `deconstantize`

给定一个带有限定常量引用表达式的字符串，[`deconstantize`][String#deconstantize]删除最右边的部分，通常只保留常量的容器名称：

```ruby
"Product".deconstantize                        # => ""
"Backoffice::UsersController".deconstantize    # => "Backoffice"
"Admin::Hotel::ReservationUtils".deconstantize # => "Admin::Hotel"
```

注意：定义在`active_support/core_ext/string/inflections.rb`中。

#### `parameterize`

方法[`parameterize`][String#parameterize]以可用于漂亮URL的方式对其接收者进行规范化。

```ruby
"John Smith".parameterize # => "john-smith"
"Kurt Gödel".parameterize # => "kurt-godel"
```

要保留字符串的大小写，将`preserve_case`参数设置为true。默认情况下，`preserve_case`设置为false。

```ruby
"John Smith".parameterize(preserve_case: true) # => "John-Smith"
"Kurt Gödel".parameterize(preserve_case: true) # => "Kurt-Godel"
```

要使用自定义分隔符，覆盖`separator`参数。
```ruby
"Employee Salary".downcase_first # => "employee Salary"
"".downcase_first                # => ""
```

NOTE: Defined in `active_support/core_ext/string/inflections.rb`.
```ruby
123.to_fs(:human)                  # => "123"
1234.to_fs(:human)                 # => "1.2 Thousand"
12345.to_fs(:human)                # => "12.3 Thousand"
1234567.to_fs(:human)              # => "1.2 Million"
1234567890.to_fs(:human)           # => "1.2 Billion"
1234567890123.to_fs(:human)        # => "1.2 Trillion"
1234567890123456.to_fs(:human)     # => "1.2 Quadrillion"
1234567890123456789.to_fs(:human)  # => "1.2 Quintillion"
```

NOTE: Defined in `active_support/core_ext/numeric/conversions.rb`.
```ruby
123.to_fs(:human)               # => "123"
1234.to_fs(:human)              # => "1.23千"
12345.to_fs(:human)             # => "12.3千"
1234567.to_fs(:human)           # => "1.23百万"
1234567890.to_fs(:human)        # => "1.23十亿"
1234567890123.to_fs(:human)     # => "1.23万亿"
1234567890123456.to_fs(:human)  # => "1.23千万亿"
```

注意：定义在 `active_support/core_ext/numeric/conversions.rb`。

`Integer` 的扩展
-----------------------

### `multiple_of?`

方法 [`multiple_of?`][Integer#multiple_of?] 用于测试一个整数是否是参数的倍数：

```ruby
2.multiple_of?(1) # => true
1.multiple_of?(2) # => false
```

注意：定义在 `active_support/core_ext/integer/multiple.rb`。


### `ordinal`

方法 [`ordinal`][Integer#ordinal] 返回与接收整数对应的序数后缀字符串：

```ruby
1.ordinal    # => "st"
2.ordinal    # => "nd"
53.ordinal   # => "rd"
2009.ordinal # => "th"
-21.ordinal  # => "st"
-134.ordinal # => "th"
```

注意：定义在 `active_support/core_ext/integer/inflections.rb`。


### `ordinalize`

方法 [`ordinalize`][Integer#ordinalize] 返回与接收整数对应的序数字符串。相比之下，注意 `ordinal` 方法只返回后缀字符串。

```ruby
1.ordinalize    # => "1st"
2.ordinalize    # => "2nd"
53.ordinalize   # => "53rd"
2009.ordinalize # => "2009th"
-21.ordinalize  # => "-21st"
-134.ordinalize # => "-134th"
```

注意：定义在 `active_support/core_ext/integer/inflections.rb`。


### 时间

以下方法：

* [`months`][Integer#months]
* [`years`][Integer#years]

可以用于时间声明和计算，比如 `4.months + 5.years`。它们的返回值也可以加减时间对象。

这些方法可以与 [`from_now`][Duration#from_now]、[`ago`][Duration#ago] 等方法结合使用，进行精确的日期计算。例如：

```ruby
# 等同于 Time.current.advance(months: 1)
1.month.from_now

# 等同于 Time.current.advance(years: 2)
2.years.from_now

# 等同于 Time.current.advance(months: 4, years: 5)
(4.months + 5.years).from_now
```

警告：对于其他持续时间，请参考对 `Numeric` 的时间扩展。

注意：定义在 `active_support/core_ext/integer/time.rb`。


`BigDecimal` 的扩展
--------------------------

### `to_s`

方法 `to_s` 提供了默认的格式说明符 "F"。这意味着简单调用 `to_s` 将得到浮点表示，而不是工程表示法：

```ruby
BigDecimal(5.00, 6).to_s       # => "5.0"
```

仍然支持工程表示法：

```ruby
BigDecimal(5.00, 6).to_s("e")  # => "0.5E1"
```

`Enumerable` 的扩展
--------------------------

### `sum`

方法 [`sum`][Enumerable#sum] 对可枚举对象的元素进行求和：

```ruby
[1, 2, 3].sum # => 6
(1..100).sum  # => 5050
```

求和假设元素可以响应 `+`：

```ruby
[[1, 2], [2, 3], [3, 4]].sum    # => [1, 2, 2, 3, 3, 4]
%w(foo bar baz).sum             # => "foobarbaz"
{ a: 1, b: 2, c: 3 }.sum          # => [:a, 1, :b, 2, :c, 3]
```

默认情况下，空集合的和为零，但可以自定义：

```ruby
[].sum    # => 0
[].sum(1) # => 1
```

如果给定了一个块，`sum` 将成为一个迭代器，遍历集合的元素并求和返回的值：

```ruby
(1..5).sum { |n| n * 2 } # => 30
[2, 4, 6, 8, 10].sum    # => 30
```

空接收者的和也可以以这种形式自定义：

```ruby
[].sum(1) { |n| n**3 } # => 1
```

注意：定义在 `active_support/core_ext/enumerable.rb`。


### `index_by`

方法 [`index_by`][Enumerable#index_by] 生成一个由可枚举对象的元素按某个键索引的哈希表。

它遍历集合并将每个元素传递给块。元素将以块返回的值作为键：

```ruby
invoices.index_by(&:number)
# => {'2009-032' => <Invoice ...>, '2009-008' => <Invoice ...>, ...}
```

警告：键通常应该是唯一的。如果块对不同的元素返回相同的值，则不会为该键构建集合。最后一个元素将获胜。

注意：定义在 `active_support/core_ext/enumerable.rb`。


### `index_with`

方法 [`index_with`][Enumerable#index_with] 生成一个由可枚举对象的元素作为键的哈希表。值可以是传递的默认值或块返回的值。

```ruby
post = Post.new(title: "hey there", body: "what's up?")

%i( title body ).index_with { |attr_name| post.public_send(attr_name) }
# => { title: "hey there", body: "what's up?" }

WEEKDAYS.index_with(Interval.all_day)
# => { monday: [ 0, 1440 ], … }
```

注意：在`active_support/core_ext/enumerable.rb`中定义。

### `many?`

方法[`many?`][Enumerable#many?]是`collection.size > 1`的简写形式：

```erb
<% if pages.many? %>
  <%= pagination_links %>
<% end %>
```

如果给定了可选的块，则`many?`只考虑返回true的元素：

```ruby
@see_more = videos.many? { |video| video.category == params[:category] }
```

注意：在`active_support/core_ext/enumerable.rb`中定义。

### `exclude?`

谓词[`exclude?`][Enumerable#exclude?]测试给定对象是否**不属于**集合。它是内置`include?`的否定形式：

```ruby
to_visit << node if visited.exclude?(node)
```

注意：在`active_support/core_ext/enumerable.rb`中定义。

### `including`

方法[`including`][Enumerable#including]返回一个包含传入元素的新的可枚举对象：

```ruby
[ 1, 2, 3 ].including(4, 5)                    # => [ 1, 2, 3, 4, 5 ]
["David", "Rafael"].including %w[ Aaron Todd ] # => ["David", "Rafael", "Aaron", "Todd"]
```

注意：在`active_support/core_ext/enumerable.rb`中定义。

### `excluding`

方法[`excluding`][Enumerable#excluding]返回一个移除了指定元素的可枚举对象的副本：

```ruby
["David", "Rafael", "Aaron", "Todd"].excluding("Aaron", "Todd") # => ["David", "Rafael"]
```

`excluding`是[`without`][Enumerable#without]的别名。

注意：在`active_support/core_ext/enumerable.rb`中定义。

### `pluck`

方法[`pluck`][Enumerable#pluck]从每个元素中提取给定的键：

```ruby
[{ name: "David" }, { name: "Rafael" }, { name: "Aaron" }].pluck(:name) # => ["David", "Rafael", "Aaron"]
[{ id: 1, name: "David" }, { id: 2, name: "Rafael" }].pluck(:id, :name) # => [[1, "David"], [2, "Rafael"]]
```

注意：在`active_support/core_ext/enumerable.rb`中定义。

### `pick`

方法[`pick`][Enumerable#pick]从第一个元素中提取给定的键：

```ruby
[{ name: "David" }, { name: "Rafael" }, { name: "Aaron" }].pick(:name) # => "David"
[{ id: 1, name: "David" }, { id: 2, name: "Rafael" }].pick(:id, :name) # => [1, "David"]
```

注意：在`active_support/core_ext/enumerable.rb`中定义。

`Array`的扩展
---------------------

### 访问

Active Support扩展了数组的API，以便更轻松地访问它们的某些方式。例如，[`to`][Array#to]返回从第一个元素到传入索引处的子数组：

```ruby
%w(a b c d).to(2) # => ["a", "b", "c"]
[].to(7)          # => []
```

类似地，[`from`][Array#from]返回从传入索引处的元素到末尾的尾部。如果索引大于数组的长度，则返回一个空数组。

```ruby
%w(a b c d).from(2)  # => ["c", "d"]
%w(a b c d).from(10) # => []
[].from(0)           # => []
```

方法[`including`][Array#including]返回一个包含传入元素的新数组：

```ruby
[ 1, 2, 3 ].including(4, 5)          # => [ 1, 2, 3, 4, 5 ]
[ [ 0, 1 ] ].including([ [ 1, 0 ] ]) # => [ [ 0, 1 ], [ 1, 0 ] ]
```

方法[`excluding`][Array#excluding]返回一个剔除了指定元素的数组的副本。这是`Enumerable#excluding`的优化版本，它使用`Array#-`而不是`Array#reject`来提高性能。

```ruby
["David", "Rafael", "Aaron", "Todd"].excluding("Aaron", "Todd") # => ["David", "Rafael"]
[ [ 0, 1 ], [ 1, 0 ] ].excluding([ [ 1, 0 ] ])                  # => [ [ 0, 1 ] ]
```

方法[`second`][Array#second]、[`third`][Array#third]、[`fourth`][Array#fourth]和[`fifth`][Array#fifth]返回对应的元素，[`second_to_last`][Array#second_to_last]和[`third_to_last`][Array#third_to_last]（`first`和`last`是内置的）也是如此。感谢社会智慧和积极建设性，[`forty_two`][Array#forty_two]也可用。

```ruby
%w(a b c d).third # => "c"
%w(a b c d).fifth # => nil
```

注意：在`active_support/core_ext/array/access.rb`中定义。

### 提取

方法[`extract!`][Array#extract!]移除并返回块返回true值的元素。如果没有给定块，则返回一个枚举器。

```ruby
numbers = [0, 1, 2, 3, 4, 5, 6, 7, 8, 9]
odd_numbers = numbers.extract! { |number| number.odd? } # => [1, 3, 5, 7, 9]
numbers # => [0, 2, 4, 6, 8]
```
注意：定义在`active_support/core_ext/array/extract.rb`中。

### 选项提取

当方法调用的最后一个参数是一个哈希表时，除了可能是一个`&block`参数之外，Ruby允许你省略括号：

```ruby
User.exists?(email: params[:email])
```

这种语法糖在Rails中经常被使用，以避免过多的位置参数，而是提供模拟命名参数的接口。特别是在使用尾部哈希表作为选项时，这是非常惯用的。

然而，如果一个方法期望接收可变数量的参数并在其声明中使用了`*`，这样一个选项哈希表最终会成为参数数组的一个元素，从而失去了它的作用。

在这种情况下，你可以使用[`extract_options!`][Array#extract_options!]方法对选项哈希表进行特殊处理。该方法检查数组的最后一个元素的类型。如果它是一个哈希表，则将其弹出并返回，否则返回一个空的哈希表。

让我们以`caches_action`控制器宏的定义为例：

```ruby
def caches_action(*actions)
  return unless cache_configured?
  options = actions.extract_options!
  # ...
end
```

这个方法接收任意数量的动作名称和一个可选的选项哈希表作为最后一个参数。通过调用`extract_options!`，你可以简单明了地获取选项哈希表并从`actions`中移除它。

注意：定义在`active_support/core_ext/array/extract_options.rb`中。

### 转换

#### `to_sentence`

[`to_sentence`][Array#to_sentence]方法将一个数组转换为一个包含列举其元素的句子的字符串：

```ruby
%w().to_sentence                # => ""
%w(Earth).to_sentence           # => "Earth"
%w(Earth Wind).to_sentence      # => "Earth and Wind"
%w(Earth Wind Fire).to_sentence # => "Earth, Wind, and Fire"
```

该方法接受三个选项：

* `:two_words_connector`：用于长度为2的数组的连接符。默认为" and "。
* `:words_connector`：用于连接具有3个或更多元素的数组的元素，除了最后两个元素。默认为", "。
* `:last_word_connector`：用于连接具有3个或更多元素的数组的最后几个元素。默认为", and "。

这些选项的默认值可以进行本地化，其键为：

| 选项                   | I18n键                               |
| ---------------------- | ----------------------------------- |
| `:two_words_connector` | `support.array.two_words_connector` |
| `:words_connector`     | `support.array.words_connector`     |
| `:last_word_connector` | `support.array.last_word_connector` |

注意：定义在`active_support/core_ext/array/conversions.rb`中。

#### `to_fs`

[`to_fs`][Array#to_fs]方法默认情况下与`to_s`类似。

然而，如果数组包含响应`id`的项，则可以将符号`:db`作为参数传递。这通常与Active Record对象的集合一起使用。返回的字符串如下：

```ruby
[].to_fs(:db)            # => "null"
[user].to_fs(:db)        # => "8456"
invoice.lines.to_fs(:db) # => "23,567,556,12"
```

上面示例中的整数应该来自于对`id`的相应调用。

注意：定义在`active_support/core_ext/array/conversions.rb`中。

#### `to_xml`

[`to_xml`][Array#to_xml]方法返回一个包含其接收者的XML表示的字符串：

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

为此，它依次向每个项发送`to_xml`，并将结果收集在一个根节点下。所有项都必须响应`to_xml`，否则会引发异常。

默认情况下，根元素的名称是第一个项的类的下划线和破折号化的复数形式，前提是其余元素属于该类型（通过`is_a?`检查），并且它们不是哈希表。在上面的示例中，根节点为"contributors"。

如果有任何元素不属于第一个元素的类型，根节点将变为"objects"：
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

如果接收者是一个哈希数组，则默认的根元素也是“objects”：

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

警告。如果集合为空，则默认的根元素是“nil-classes”。这是一个陷阱，例如上面的贡献者列表的根元素如果集合为空，则不是“contributors”，而是“nil-classes”。您可以使用`:root`选项来确保一致的根元素。

子节点的名称默认为根节点的单数形式。在上面的示例中，我们看到了“contributor”和“object”。选项`:children`允许您设置这些节点名称。

默认的XML构建器是`Builder::XmlMarkup`的一个新实例。您可以通过`:builder`选项配置自己的构建器。该方法还接受诸如`:dasherize`等选项，它们被转发给构建器：

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

注意：定义在`active_support/core_ext/array/conversions.rb`中。


### 包装

方法[`Array.wrap`][Array.wrap]将其参数包装在一个数组中，除非它已经是一个数组（或类似数组）。

具体来说：

* 如果参数是`nil`，则返回一个空数组。
* 否则，如果参数响应`to_ary`，则调用它，如果`to_ary`的值不是`nil`，则返回它。
* 否则，返回一个以参数为其单个元素的数组。

```ruby
Array.wrap(nil)       # => []
Array.wrap([1, 2, 3]) # => [1, 2, 3]
Array.wrap(0)         # => [0]
```

此方法的目的类似于`Kernel#Array`，但有一些区别：

* 如果参数响应`to_ary`，则调用该方法。`Kernel#Array`继续尝试`to_a`，如果返回的值为`nil`，但`Array.wrap`立即返回一个以参数为其单个元素的数组。
* 如果`to_ary`返回的值既不是`nil`也不是`Array`对象，`Kernel#Array`会引发异常，而`Array.wrap`不会，它只返回该值。
* 如果参数不响应`to_ary`，则不会调用`to_a`，而是返回一个以参数为其单个元素的数组。

最后一点特别值得比较一下对于一些可枚举对象：

```ruby
Array.wrap(foo: :bar) # => [{:foo=>:bar}]
Array(foo: :bar)      # => [[:foo, :bar]]
```

还有一个相关的惯用法使用了展开运算符：

```ruby
[*object]
```

注意：定义在`active_support/core_ext/array/wrap.rb`中。


### 复制

方法[`Array#deep_dup`][Array#deep_dup]使用Active Support方法`Object#deep_dup`递归地复制自身和内部的所有对象。它的工作方式类似于`Array#map`，将`deep_dup`方法发送给内部的每个对象。

```ruby
array = [1, [2, 3]]
dup = array.deep_dup
dup[1][2] = 4
array[1][2] == nil   # => true
```

注意：定义在`active_support/core_ext/object/deep_dup.rb`中。


### 分组

#### `in_groups_of(number, fill_with = nil)`

方法[`in_groups_of`][Array#in_groups_of]将数组分成连续的一组，每组的大小为指定的大小。它返回一个包含这些组的数组：

```ruby
[1, 2, 3].in_groups_of(2) # => [[1, 2], [3, nil]]
```

或者如果传递了一个块，则按顺序生成它们：

```html+erb
<% sample.in_groups_of(3) do |a, b, c| %>
  <tr>
    <td><%= a %></td>
    <td><%= b %></td>
    <td><%= c %></td>
  </tr>
<% end %>
```

第一个示例展示了`in_groups_of`如何使用尽可能多的`nil`元素填充最后一组，以达到所需的大小。您可以使用第二个可选参数更改此填充值：

```ruby
[1, 2, 3].in_groups_of(2, 0) # => [[1, 2], [3, 0]]
```

您还可以通过传递`false`来告诉方法不要填充最后一组：

```ruby
[1, 2, 3].in_groups_of(2, false) # => [[1, 2], [3]]
```

因此，`false`不能用作填充值。

注意：定义在`active_support/core_ext/array/grouping.rb`中。


#### `in_groups(number, fill_with = nil)`

方法[`in_groups`][Array#in_groups]将数组分成一定数量的组。该方法返回一个包含这些组的数组：

```ruby
%w(1 2 3 4 5 6 7).in_groups(3)
# => [["1", "2", "3"], ["4", "5", nil], ["6", "7", nil]]
```

或者如果传递了一个块，则按顺序生成它们：

```ruby
%w(1 2 3 4 5 6 7).in_groups(3) { |group| p group }
["1", "2", "3"]
["4", "5", nil]
["6", "7", nil]
```

上面的示例显示`in_groups`如何根据需要使用尾随的`nil`元素填充一些组。一个组最多可以获得一个额外的元素，如果有的话，总是最右边的元素。具有这些额外元素的组始终是最后一组。

您可以使用第二个可选参数更改此填充值：

```ruby
%w(1 2 3 4 5 6 7).in_groups(3, "0")
# => [["1", "2", "3"], ["4", "5", "0"], ["6", "7", "0"]]
```

您还可以通过传递`false`来告诉方法不要填充较小的组：

```ruby
%w(1 2 3 4 5 6 7).in_groups(3, false)
# => [["1", "2", "3"], ["4", "5"], ["6", "7"]]
```

因此，`false`不能用作填充值。

注意：定义在`active_support/core_ext/array/grouping.rb`中。


#### `split(value = nil)`

方法[`split`][Array#split]通过分隔符将数组分割并返回结果块。

如果传递了一个块，则分隔符是数组中使块返回true的元素：

```ruby
(-5..5).to_a.split { |i| i.multiple_of?(4) }
# => [[-5], [-3, -2, -1], [1, 2, 3], [5]]
```

否则，接收到的参数值（默认为`nil`）是分隔符：

```ruby
[0, 1, -5, 1, 1, "foo", "bar"].split(1)
# => [[0], [-5], [], ["foo", "bar"]]
```

提示：观察前面的示例，连续的分隔符会导致空数组。

注意：定义在`active_support/core_ext/array/grouping.rb`中。


`Hash`的扩展
--------------------

### 转换

#### `to_xml`

方法[`to_xml`][Hash#to_xml]返回一个包含其接收者的XML表示的字符串：

```ruby
{ foo: 1, bar: 2 }.to_xml
# =>
# <?xml version="1.0" encoding="UTF-8"?>
# <hash>
#   <foo type="integer">1</foo>
#   <bar type="integer">2</bar>
# </hash>
```

为此，该方法循环遍历键值对，并构建依赖于_values_的节点。给定一对`key`，`value`：

* 如果`value`是一个哈希表，则使用`key`作为`:root`进行递归调用。

* 如果`value`是一个数组，则使用`key`作为`:root`和`key`的单数形式作为`:children`进行递归调用。

* 如果`value`是一个可调用对象，则它必须接受一个或两个参数。根据参数个数，使用`options`哈希作为第一个参数和`key`的单数形式作为第二个参数调用可调用对象。其返回值成为一个新节点。

* 如果`value`响应`to_xml`方法，则使用`key`作为`:root`进行调用。

* 否则，创建一个以`key`为标签的节点，其文本节点为`value`的字符串表示。如果`value`为`nil`，则添加一个设置为"true"的属性"nil"。除非存在且为true的选项`:skip_types`，否则还会根据以下映射添加一个名为"type"的属性：
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

默认情况下，根节点是“hash”，但可以通过`:root`选项进行配置。

默认的XML构建器是`Builder::XmlMarkup`的一个新实例。您可以使用`:builder`选项配置自己的构建器。该方法还接受诸如`:dasherize`等选项，它们会被转发给构建器。

注意：定义在`active_support/core_ext/hash/conversions.rb`中。


### 合并

Ruby有一个内置的方法`Hash#merge`，用于合并两个哈希：

```ruby
{ a: 1, b: 1 }.merge(a: 0, c: 2)
# => {:a=>0, :b=>1, :c=>2}
```

Active Support定义了一些更方便的合并哈希的方法。

#### `reverse_merge`和`reverse_merge!`

在`merge`中，如果哈希参数中的键冲突，参数中的键将覆盖原哈希中的键。您可以使用以下习惯用法以紧凑的方式支持具有默认值的选项哈希：

```ruby
options = { length: 30, omission: "..." }.merge(options)
```

Active Support定义了[`reverse_merge`][Hash#reverse_merge]，以便您可以使用以下替代符号：

```ruby
options = options.reverse_merge(length: 30, omission: "...")
```

还有一个带有感叹号的版本[`reverse_merge!`][Hash#reverse_merge!]，它会就地执行合并操作：

```ruby
options.reverse_merge!(length: 30, omission: "...")
```

警告：请注意，`reverse_merge!`可能会更改调用者中的哈希，这可能是好事，也可能不是好事。

注意：定义在`active_support/core_ext/hash/reverse_merge.rb`中。


#### `reverse_update`

方法[`reverse_update`][Hash#reverse_update]是`reverse_merge!`的别名，如上所述。

警告：请注意，`reverse_update`没有感叹号。

注意：定义在`active_support/core_ext/hash/reverse_merge.rb`中。


#### `deep_merge`和`deep_merge!`

如前面的示例所示，如果在两个哈希中都找到了一个键，则参数中的值将覆盖原哈希中的值。

Active Support定义了[`Hash#deep_merge`][Hash#deep_merge]。在深度合并中，如果在两个哈希中都找到了一个键，并且它们的值也是哈希，则它们的合并将成为结果哈希中的值：

```ruby
{ a: { b: 1 } }.deep_merge(a: { c: 2 })
# => {:a=>{:b=>1, :c=>2}}
```

方法[`deep_merge!`][Hash#deep_merge!]会就地执行深度合并。

注意：定义在`active_support/core_ext/hash/deep_merge.rb`中。


### 深度复制

方法[`Hash#deep_dup`][Hash#deep_dup]使用Active Support方法`Object#deep_dup`递归地复制自身及其所有键和值。它的工作方式类似于`Enumerator#each_with_object`，将`deep_dup`方法发送给每个键值对。

```ruby
hash = { a: 1, b: { c: 2, d: [3, 4] } }

dup = hash.deep_dup
dup[:b][:e] = 5
dup[:b][:d] << 5

hash[:b][:e] == nil      # => true
hash[:b][:d] == [3, 4]   # => true
```

注意：定义在`active_support/core_ext/object/deep_dup.rb`中。


### 处理键

#### `except`和`except!`

方法[`except`][Hash#except]返回一个删除了参数列表中存在的键的哈希：

```ruby
{ a: 1, b: 2 }.except(:a) # => {:b=>2}
```

如果接收者响应`convert_key`，则在每个参数上调用该方法。这使得`except`可以与具有无关键访问的哈希很好地配合使用，例如：

```ruby
{ a: 1 }.with_indifferent_access.except(:a)  # => {}
{ a: 1 }.with_indifferent_access.except("a") # => {}
```

还有一个带有感叹号的变体[`except!`][Hash#except!]，它会就地删除键。

注意：定义在`active_support/core_ext/hash/except.rb`中。


#### `stringify_keys`和`stringify_keys!`

方法[`stringify_keys`][Hash#stringify_keys]返回一个在接收者中将键的字符串化版本的哈希。它通过向键发送`to_s`来实现：

```ruby
{ nil => nil, 1 => 1, a: :a }.stringify_keys
# => {"" => nil, "1" => 1, "a" => :a}
```

在键冲突的情况下，值将是最近插入到哈希中的值：

```ruby
{ "a" => 1, a: 2 }.stringify_keys
# 结果将是
# => {"a"=>2}
```

这种方法可能很有用，例如可以轻松地接受符号和字符串作为选项。例如，`ActionView::Helpers::FormHelper` 定义了：

```ruby
def to_check_box_tag(options = {}, checked_value = "1", unchecked_value = "0")
  options = options.stringify_keys
  options["type"] = "checkbox"
  # ...
end
```

第二行可以安全地访问 "type" 键，并允许用户传递 `:type` 或 "type"。

还有 [`stringify_keys!`][Hash#stringify_keys!] 的变体，它可以原地将键字符串化。

除此之外，还可以使用 [`deep_stringify_keys`][Hash#deep_stringify_keys] 和 [`deep_stringify_keys!`][Hash#deep_stringify_keys!] 来将给定哈希中的所有键和嵌套在其中的所有哈希字符串化。结果的示例如下：

```ruby
{ nil => nil, 1 => 1, nested: { a: 3, 5 => 5 } }.deep_stringify_keys
# => {""=>nil, "1"=>1, "nested"=>{"a"=>3, "5"=>5}}
```

注意：定义在 `active_support/core_ext/hash/keys.rb` 中。


#### `symbolize_keys` 和 `symbolize_keys!`

[`symbolize_keys`][Hash#symbolize_keys] 方法返回一个哈希，其中包含接收者键的符号化版本（如果可能）。它通过向键发送 `to_sym` 来实现：

```ruby
{ nil => nil, 1 => 1, "a" => "a" }.symbolize_keys
# => {nil=>nil, 1=>1, :a=>"a"}
```

警告：请注意，在前面的示例中，只有一个键被符号化。

在键冲突的情况下，值将是最近插入到哈希中的值：

```ruby
{ "a" => 1, a: 2 }.symbolize_keys
# => {:a=>2}
```

这种方法可能很有用，例如可以轻松地接受符号和字符串作为选项。例如，`ActionText::TagHelper` 定义了：

```ruby
def rich_text_area_tag(name, value = nil, options = {})
  options = options.symbolize_keys

  options[:input] ||= "trix_input_#{ActionText::TagHelper.id += 1}"
  # ...
end
```

第三行可以安全地访问 `:input` 键，并允许用户传递 `:input` 或 "input"。

还有 [`symbolize_keys!`][Hash#symbolize_keys!] 的变体，它可以原地将键符号化。

除此之外，还可以使用 [`deep_symbolize_keys`][Hash#deep_symbolize_keys] 和 [`deep_symbolize_keys!`][Hash#deep_symbolize_keys!] 来将给定哈希中的所有键和嵌套在其中的所有哈希符号化。结果的示例如下：

```ruby
{ nil => nil, 1 => 1, "nested" => { "a" => 3, 5 => 5 } }.deep_symbolize_keys
# => {nil=>nil, 1=>1, nested:{a:3, 5=>5}}
```

注意：定义在 `active_support/core_ext/hash/keys.rb` 中。


#### `to_options` 和 `to_options!`

[`to_options`][Hash#to_options] 和 [`to_options!`][Hash#to_options!] 方法是 `symbolize_keys` 和 `symbolize_keys!` 的别名。

注意：定义在 `active_support/core_ext/hash/keys.rb` 中。


#### `assert_valid_keys`

[`assert_valid_keys`][Hash#assert_valid_keys] 方法接收任意数量的参数，并检查接收者是否有任何不在该列表中的键。如果有，则引发 `ArgumentError`。

```ruby
{ a: 1 }.assert_valid_keys(:a)  # 通过
{ a: 1 }.assert_valid_keys("a") # ArgumentError
```

例如，在构建关联时，Active Record 不接受未知选项。它通过 `assert_valid_keys` 实现该控制。

注意：定义在 `active_support/core_ext/hash/keys.rb` 中。


### 处理值

#### `deep_transform_values` 和 `deep_transform_values!`

[`deep_transform_values`][Hash#deep_transform_values] 方法返回一个通过块操作转换所有值的新哈希。这包括根哈希和所有嵌套的哈希和数组的值。

```ruby
hash = { person: { name: 'Rob', age: '28' } }

hash.deep_transform_values { |value| value.to_s.upcase }
# => {person: {name: "ROB", age: "28"}}
```

还有 [`deep_transform_values!`][Hash#deep_transform_values!] 的变体，它通过使用块操作来破坏性地转换所有值。

注意：定义在 `active_support/core_ext/hash/deep_transform_values.rb` 中。


### 切片

[`slice!`][Hash#slice!] 方法用给定的键替换哈希，并返回一个包含已删除的键/值对的哈希。

```ruby
hash = { a: 1, b: 2 }
rest = hash.slice!(:a) # => {:b=>2}
hash                   # => {:a=>1}
```

注意：定义在 `active_support/core_ext/hash/slice.rb` 中。


### 提取

[`extract!`][Hash#extract!] 方法删除并返回与给定键匹配的键/值对。

```ruby
hash = { a: 1, b: 2 }
rest = hash.extract!(:a) # => {:a=>1}
hash                     # => {:b=>2}
```

`extract!` 方法返回与接收者相同的 Hash 子类。
```ruby
hash = { a: 1, b: 2 }.with_indifferent_access
rest = hash.extract!(:a).class
# => ActiveSupport::HashWithIndifferentAccess
```

注意：定义在 `active_support/core_ext/hash/slice.rb` 中。


### 无差别访问

方法 [`with_indifferent_access`][Hash#with_indifferent_access] 返回一个 [`ActiveSupport::HashWithIndifferentAccess`][ActiveSupport::HashWithIndifferentAccess] 对象：

```ruby
{ a: 1 }.with_indifferent_access["a"] # => 1
```

注意：定义在 `active_support/core_ext/hash/indifferent_access.rb` 中。


`Regexp` 的扩展
----------------------

### `multiline?`

方法 [`multiline?`][Regexp#multiline?] 判断一个正则表达式是否设置了 `/m` 标志，即点是否匹配换行符。

```ruby
%r{.}.multiline?  # => false
%r{.}m.multiline? # => true

Regexp.new('.').multiline?                    # => false
Regexp.new('.', Regexp::MULTILINE).multiline? # => true
```

Rails 在路由代码中也使用了这个方法。多行正则表达式在路由要求中是不允许的，这个标志可以方便地强制执行这个约束。

```ruby
def verify_regexp_requirements(requirements)
  # ...
  if requirement.multiline?
    raise ArgumentError, "Regexp multiline option is not allowed in routing requirements: #{requirement.inspect}"
  end
  # ...
end
```

注意：定义在 `active_support/core_ext/regexp.rb` 中。


`Range` 的扩展
---------------------

### `to_fs`

Active Support 定义了 `Range#to_fs` 作为 `to_s` 的替代方法，它可以接受一个可选的格式参数。截至目前，唯一支持的非默认格式是 `:db`：

```ruby
(Date.today..Date.tomorrow).to_fs
# => "2009-10-25..2009-10-26"

(Date.today..Date.tomorrow).to_fs(:db)
# => "BETWEEN '2009-10-25' AND '2009-10-26'"
```

如示例所示，`：db` 格式生成一个 `BETWEEN` SQL 子句。Active Record 在条件中支持范围值时使用了这个子句。

注意：定义在 `active_support/core_ext/range/conversions.rb` 中。

### `===` 和 `include?`

方法 `Range#===` 和 `Range#include?` 判断某个值是否在给定范围的两端之间：

```ruby
(2..3).include?(Math::E) # => true
```

Active Support 扩展了这些方法，使得参数也可以是另一个范围。在这种情况下，我们测试参数范围的两端是否属于接收者本身：

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

注意：定义在 `active_support/core_ext/range/compare_range.rb` 中。

### `overlap?`

方法 [`Range#overlap?`][Range#overlap?] 判断两个给定范围是否有非空交集：

```ruby
(1..10).overlap?(7..11)  # => true
(1..10).overlap?(0..7)   # => true
(1..10).overlap?(11..27) # => false
```

注意：定义在 `active_support/core_ext/range/overlap.rb` 中。


`Date` 的扩展
--------------------

### 计算

INFO: 以下计算方法在 1582 年 10 月存在特殊情况，因为第 5 到 14 天根本不存在。为了简洁起见，本指南不会详细说明这些方法在这些日期周围的行为，但可以肯定的是它们会按照你的预期工作。也就是说，`Date.new(1582, 10, 4).tomorrow` 返回 `Date.new(1582, 10, 15)`，以此类推。请查看 Active Support 测试套件中的 `test/core_ext/date_ext_test.rb` 文件以获取预期的行为。

#### `Date.current`

Active Support 定义了 [`Date.current`][Date.current] 作为当前时区的今天日期。它类似于 `Date.today`，但会尊重用户的时区设置（如果定义）。它还定义了 [`Date.yesterday`][Date.yesterday] 和 [`Date.tomorrow`][Date.tomorrow]，以及实例谓词 [`past?`][DateAndTime::Calculations#past?]、[`today?`][DateAndTime::Calculations#today?]、[`tomorrow?`][DateAndTime::Calculations#tomorrow?]、[`next_day?`][DateAndTime::Calculations#next_day?]、[`yesterday?`][DateAndTime::Calculations#yesterday?]、[`prev_day?`][DateAndTime::Calculations#prev_day?]、[`future?`][DateAndTime::Calculations#future?]、[`on_weekday?`][DateAndTime::Calculations#on_weekday?] 和 [`on_weekend?`][DateAndTime::Calculations#on_weekend?]，它们都是相对于 `Date.current` 的。

在使用尊重用户时区的方法进行日期比较时，请确保使用 `Date.current` 而不是 `Date.today`。有些情况下，用户时区可能比系统时区更靠未来，而 `Date.today` 默认使用系统时区。这意味着 `Date.today` 可能等于 `Date.yesterday`。

注意：定义在 `active_support/core_ext/date/calculations.rb` 中。


#### 命名日期

##### `beginning_of_week`, `end_of_week`

方法 [`beginning_of_week`][DateAndTime::Calculations#beginning_of_week] 和 [`end_of_week`][DateAndTime::Calculations#end_of_week] 分别返回一周的开始和结束日期。默认情况下，一周从星期一开始，但可以通过传递参数、设置线程本地的 `Date.beginning_of_week` 或 [`config.beginning_of_week`][] 来更改。

```ruby
d = Date.new(2010, 5, 8)     # => Sat, 08 May 2010
d.beginning_of_week          # => Mon, 03 May 2010
d.beginning_of_week(:sunday) # => Sun, 02 May 2010
d.end_of_week                # => Sun, 09 May 2010
d.end_of_week(:sunday)       # => Sat, 08 May 2010
```

`beginning_of_week` 被别名为 [`at_beginning_of_week`][DateAndTime::Calculations#at_beginning_of_week]，`end_of_week` 被别名为 [`at_end_of_week`][DateAndTime::Calculations#at_end_of_week]。

注意：定义在 `active_support/core_ext/date_and_time/calculations.rb` 中。


##### `monday`, `sunday`

[`monday`][DateAndTime::Calculations#monday] 和 [`sunday`][DateAndTime::Calculations#sunday] 方法分别返回上一个星期一和下一个星期日的日期。

```ruby
d = Date.new(2010, 5, 8)     # => Sat, 08 May 2010
d.monday                     # => Mon, 03 May 2010
d.sunday                     # => Sun, 09 May 2010

d = Date.new(2012, 9, 10)    # => Mon, 10 Sep 2012
d.monday                     # => Mon, 10 Sep 2012

d = Date.new(2012, 9, 16)    # => Sun, 16 Sep 2012
d.sunday                     # => Sun, 16 Sep 2012
```

注意：定义在 `active_support/core_ext/date_and_time/calculations.rb` 中。


##### `prev_week`, `next_week`

[`next_week`][DateAndTime::Calculations#next_week] 方法接收一个英文星期几的符号（默认为线程本地的 [`Date.beginning_of_week`][Date.beginning_of_week]，或 [`config.beginning_of_week`][]，或 `:monday`），并返回对应的日期。

```ruby
d = Date.new(2010, 5, 9) # => Sun, 09 May 2010
d.next_week              # => Mon, 10 May 2010
d.next_week(:saturday)   # => Sat, 15 May 2010
```

[`prev_week`][DateAndTime::Calculations#prev_week] 方法类似：

```ruby
d.prev_week              # => Mon, 26 Apr 2010
d.prev_week(:saturday)   # => Sat, 01 May 2010
d.prev_week(:friday)     # => Fri, 30 Apr 2010
```

`prev_week` 被别名为 [`last_week`][DateAndTime::Calculations#last_week]。

当设置了 `Date.beginning_of_week` 或 `config.beginning_of_week` 时，`next_week` 和 `prev_week` 的行为如预期。

注意：定义在 `active_support/core_ext/date_and_time/calculations.rb` 中。


##### `beginning_of_month`, `end_of_month`

[`beginning_of_month`][DateAndTime::Calculations#beginning_of_month] 和 [`end_of_month`][DateAndTime::Calculations#end_of_month] 方法分别返回月份的开始和结束日期：

```ruby
d = Date.new(2010, 5, 9) # => Sun, 09 May 2010
d.beginning_of_month     # => Sat, 01 May 2010
d.end_of_month           # => Mon, 31 May 2010
```

`beginning_of_month` 被别名为 [`at_beginning_of_month`][DateAndTime::Calculations#at_beginning_of_month]，`end_of_month` 被别名为 [`at_end_of_month`][DateAndTime::Calculations#at_end_of_month]。

注意：定义在 `active_support/core_ext/date_and_time/calculations.rb` 中。


##### `quarter`, `beginning_of_quarter`, `end_of_quarter`

[`quarter`][DateAndTime::Calculations#quarter] 方法返回接收者所在日历年的季度：

```ruby
d = Date.new(2010, 5, 9) # => Sun, 09 May 2010
d.quarter                # => 2
```

[`beginning_of_quarter`][DateAndTime::Calculations#beginning_of_quarter] 和 [`end_of_quarter`][DateAndTime::Calculations#end_of_quarter] 方法分别返回接收者所在日历年季度的开始和结束日期：

```ruby
d = Date.new(2010, 5, 9) # => Sun, 09 May 2010
d.beginning_of_quarter   # => Thu, 01 Apr 2010
d.end_of_quarter         # => Wed, 30 Jun 2010
```

`beginning_of_quarter` 被别名为 [`at_beginning_of_quarter`][DateAndTime::Calculations#at_beginning_of_quarter]，`end_of_quarter` 被别名为 [`at_end_of_quarter`][DateAndTime::Calculations#at_end_of_quarter]。

注意：定义在 `active_support/core_ext/date_and_time/calculations.rb` 中。


##### `beginning_of_year`, `end_of_year`

[`beginning_of_year`][DateAndTime::Calculations#beginning_of_year] 和 [`end_of_year`][DateAndTime::Calculations#end_of_year] 方法分别返回年份的开始和结束日期：

```ruby
d = Date.new(2010, 5, 9) # => Sun, 09 May 2010
d.beginning_of_year      # => Fri, 01 Jan 2010
d.end_of_year            # => Fri, 31 Dec 2010
```

`beginning_of_year` 被别名为 [`at_beginning_of_year`][DateAndTime::Calculations#at_beginning_of_year]，`end_of_year` 被别名为 [`at_end_of_year`][DateAndTime::Calculations#at_end_of_year]。

注意：定义在 `active_support/core_ext/date_and_time/calculations.rb` 中。


#### 其他日期计算

##### `years_ago`, `years_since`

[`years_ago`][DateAndTime::Calculations#years_ago] 方法接收一个年数，返回对应年数前的同一日期：

```ruby
date = Date.new(2010, 6, 7)
date.years_ago(10) # => Wed, 07 Jun 2000
```

[`years_since`][DateAndTime::Calculations#years_since] 方法向前移动时间：

```ruby
date = Date.new(2010, 6, 7)
date.years_since(10) # => Sun, 07 Jun 2020
```

如果这样的日期不存在，则返回对应月份的最后一天：

```ruby
Date.new(2012, 2, 29).years_ago(3)     # => Sat, 28 Feb 2009
Date.new(2012, 2, 29).years_since(3)   # => Sat, 28 Feb 2015
```

[`last_year`][DateAndTime::Calculations#last_year] 是 `#years_ago(1)` 的简写。

注意：定义在 `active_support/core_ext/date_and_time/calculations.rb` 中。


##### `months_ago`, `months_since`

[`months_ago`][DateAndTime::Calculations#months_ago] 和 [`months_since`][DateAndTime::Calculations#months_since] 方法对月份的计算类似：

```ruby
Date.new(2010, 4, 30).months_ago(2)   # => Sun, 28 Feb 2010
Date.new(2010, 4, 30).months_since(2) # => Wed, 30 Jun 2010
```

如果这样的日期不存在，则返回对应月份的最后一天：

```ruby
Date.new(2010, 4, 30).months_ago(2)    # => Sun, 28 Feb 2010
Date.new(2009, 12, 31).months_since(2) # => Sun, 28 Feb 2010
```

[`last_month`][DateAndTime::Calculations#last_month] 是 `#months_ago(1)` 的简写。
注意：在`active_support/core_ext/date_and_time/calculations.rb`中定义。

##### `weeks_ago`

[`weeks_ago`][DateAndTime::Calculations#weeks_ago]方法的工作方式与周类似：

```ruby
Date.new(2010, 5, 24).weeks_ago(1)    # => Mon, 17 May 2010
Date.new(2010, 5, 24).weeks_ago(2)    # => Mon, 10 May 2010
```

注意：在`active_support/core_ext/date_and_time/calculations.rb`中定义。

##### `advance`

跳转到其他日期的最通用方法是[`advance`][Date#advance]。该方法接收一个哈希，其中包含`：years`、`：months`、`：weeks`、`：days`等键，并返回根据这些键所指示的日期：

```ruby
date = Date.new(2010, 6, 6)
date.advance(years: 1, weeks: 2)  # => Mon, 20 Jun 2011
date.advance(months: 2, days: -2) # => Wed, 04 Aug 2010
```

请注意，在上面的示例中，增量可以是负数。

注意：在`active_support/core_ext/date/calculations.rb`中定义。

#### 更改组件

[`change`][Date#change]方法允许您获取一个与接收者相同的新日期，除了给定的年、月或日之外：

```ruby
Date.new(2010, 12, 23).change(year: 2011, month: 11)
# => Wed, 23 Nov 2011
```

如果更改无效，则此方法不容忍不存在的日期，将引发`ArgumentError`：

```ruby
Date.new(2010, 1, 31).change(month: 2)
# => ArgumentError: invalid date
```

注意：在`active_support/core_ext/date/calculations.rb`中定义。

#### 持续时间

可以将[`Duration`][ActiveSupport::Duration]对象添加到日期中或从日期中减去：

```ruby
d = Date.current
# => Mon, 09 Aug 2010
d + 1.year
# => Tue, 09 Aug 2011
d - 3.hours
# => Sun, 08 Aug 2010 21:00:00 UTC +00:00
```

它们转换为对`since`或`advance`的调用。例如，在这里我们得到了正确的日历改革跳跃：

```ruby
Date.new(1582, 10, 4) + 1.day
# => Fri, 15 Oct 1582
```

#### 时间戳

INFO：如果可能，以下方法返回一个`Time`对象，否则返回一个`DateTime`对象。如果设置了，它们会遵守用户的时区。

##### `beginning_of_day`，`end_of_day`

[`beginning_of_day`][Date#beginning_of_day]方法返回一天的开始时间戳（00:00:00）：

```ruby
date = Date.new(2010, 6, 7)
date.beginning_of_day # => Mon Jun 07 00:00:00 +0200 2010
```

[`end_of_day`][Date#end_of_day]方法返回一天的结束时间戳（23:59:59）：

```ruby
date = Date.new(2010, 6, 7)
date.end_of_day # => Mon Jun 07 23:59:59 +0200 2010
```

`beginning_of_day`被别名为[`at_beginning_of_day`][Date#at_beginning_of_day]、[`midnight`][Date#midnight]、[`at_midnight`][Date#at_midnight]。

注意：在`active_support/core_ext/date/calculations.rb`中定义。

##### `beginning_of_hour`，`end_of_hour`

[`beginning_of_hour`][DateTime#beginning_of_hour]方法返回一个小时的开始时间戳（hh:00:00）：

```ruby
date = DateTime.new(2010, 6, 7, 19, 55, 25)
date.beginning_of_hour # => Mon Jun 07 19:00:00 +0200 2010
```

[`end_of_hour`][DateTime#end_of_hour]方法返回一个小时的结束时间戳（hh:59:59）：

```ruby
date = DateTime.new(2010, 6, 7, 19, 55, 25)
date.end_of_hour # => Mon Jun 07 19:59:59 +0200 2010
```

`beginning_of_hour`被别名为[`at_beginning_of_hour`][DateTime#at_beginning_of_hour]。

注意：在`active_support/core_ext/date_time/calculations.rb`中定义。

##### `beginning_of_minute`，`end_of_minute`

[`beginning_of_minute`][DateTime#beginning_of_minute]方法返回一分钟的开始时间戳（hh:mm:00）：

```ruby
date = DateTime.new(2010, 6, 7, 19, 55, 25)
date.beginning_of_minute # => Mon Jun 07 19:55:00 +0200 2010
```

[`end_of_minute`][DateTime#end_of_minute]方法返回一分钟的结束时间戳（hh:mm:59）：

```ruby
date = DateTime.new(2010, 6, 7, 19, 55, 25)
date.end_of_minute # => Mon Jun 07 19:55:59 +0200 2010
```

`beginning_of_minute`被别名为[`at_beginning_of_minute`][DateTime#at_beginning_of_minute]。

INFO：`beginning_of_hour`，`end_of_hour`，`beginning_of_minute`和`end_of_minute`适用于`Time`和`DateTime`，但不适用于`Date`，因为在`Date`实例上请求小时或分钟的开始或结束没有意义。

注意：在`active_support/core_ext/date_time/calculations.rb`中定义。

##### `ago`，`since`

[`ago`][Date#ago]方法接收一个以秒为单位的数字作为参数，并返回从午夜开始的指定秒数之前的时间戳：

```ruby
date = Date.current # => Fri, 11 Jun 2010
date.ago(1)         # => Thu, 10 Jun 2010 23:59:59 EDT -04:00
```

类似地，[`since`][Date#since]向前移动：

```ruby
date = Date.current # => Fri, 11 Jun 2010
date.since(1)       # => Fri, 11 Jun 2010 00:00:01 EDT -04:00
```
注意：在`active_support/core_ext/date/calculations.rb`中定义。

`DateTime`的扩展
------------------------

警告：`DateTime`不了解夏令时规则，因此在夏令时变化时，其中一些方法可能存在边界情况。例如，[`seconds_since_midnight`][DateTime#seconds_since_midnight]在这一天可能不会返回实际的秒数。

### 计算

`DateTime`类是`Date`类的子类，因此通过加载`active_support/core_ext/date/calculations.rb`，您继承了这些方法及其别名，只是它们始终返回日期时间。

以下方法已重新实现，因此您**不需要**为这些方法加载`active_support/core_ext/date/calculations.rb`：

* [`beginning_of_day`][DateTime#beginning_of_day] / [`midnight`][DateTime#midnight] / [`at_midnight`][DateTime#at_midnight] / [`at_beginning_of_day`][DateTime#at_beginning_of_day]
* [`end_of_day`][DateTime#end_of_day]
* [`ago`][DateTime#ago]
* [`since`][DateTime#since] / [`in`][DateTime#in]

另一方面，[`advance`][DateTime#advance]和[`change`][DateTime#change]也被定义并支持更多选项，下面将对其进行说明。

以下方法仅在`active_support/core_ext/date_time/calculations.rb`中实现，因为它们只在与`DateTime`实例一起使用时才有意义：

* [`beginning_of_hour`][DateTime#beginning_of_hour] / [`at_beginning_of_hour`][DateTime#at_beginning_of_hour]
* [`end_of_hour`][DateTime#end_of_hour]


#### 命名的日期时间

##### `DateTime.current`

Active Support定义[`DateTime.current`][DateTime.current]类似于`Time.now.to_datetime`，只是它遵守用户的时区（如果定义）。实例谓词[`past?`][DateAndTime::Calculations#past?]和[`future?`][DateAndTime::Calculations#future?]相对于`DateTime.current`进行定义。

注意：在`active_support/core_ext/date_time/calculations.rb`中定义。


#### 其他扩展

##### `seconds_since_midnight`

方法[`seconds_since_midnight`][DateTime#seconds_since_midnight]返回从午夜以来的秒数：

```ruby
now = DateTime.current     # => Mon, 07 Jun 2010 20:26:36 +0000
now.seconds_since_midnight # => 73596
```

注意：在`active_support/core_ext/date_time/calculations.rb`中定义。


##### `utc`

方法[`utc`][DateTime#utc]以UTC表示方式给出与接收器相同的日期时间。

```ruby
now = DateTime.current # => Mon, 07 Jun 2010 19:27:52 -0400
now.utc                # => Mon, 07 Jun 2010 23:27:52 +0000
```

该方法也被别名为[`getutc`][DateTime#getutc]。

注意：在`active_support/core_ext/date_time/calculations.rb`中定义。


##### `utc?`

谓词[`utc?`][DateTime#utc?]表示接收器是否具有UTC作为其时区：

```ruby
now = DateTime.now # => Mon, 07 Jun 2010 19:30:47 -0400
now.utc?           # => false
now.utc.utc?       # => true
```

注意：在`active_support/core_ext/date_time/calculations.rb`中定义。


##### `advance`

跳转到另一个日期时间的最通用方法是[`advance`][DateTime#advance]。该方法接收一个哈希，其中包含键`：years`，`：months`，`：weeks`，`：days`，`：hours`，`：minutes`和`：seconds`，并返回根据这些键指示的时间量进行推进的日期时间。

```ruby
d = DateTime.current
# => Thu, 05 Aug 2010 11:33:31 +0000
d.advance(years: 1, months: 1, days: 1, hours: 1, minutes: 1, seconds: 1)
# => Tue, 06 Sep 2011 12:34:32 +0000
```

该方法首先使用`：years`，`：months`，`：weeks`和`：days`将目标日期计算为`Date#advance`中所述。然后，它调用[`since`][DateTime#since]并传递要推进的秒数来调整时间。这个顺序是相关的，不同的顺序会在某些边界情况下给出不同的日期时间。`Date#advance`中的示例适用，并且我们可以扩展它以显示与时间位相关的顺序相关性。

如果我们首先移动日期位（这些位也有一个相对的处理顺序，如前面所述），然后再移动时间位，我们会得到以下计算结果：

```ruby
d = DateTime.new(2010, 2, 28, 23, 59, 59)
# => Sun, 28 Feb 2010 23:59:59 +0000
d.advance(months: 1, seconds: 1)
# => Mon, 29 Mar 2010 00:00:00 +0000
```

但是，如果我们以相反的顺序计算它们，结果将不同：

```ruby
d.advance(seconds: 1).advance(months: 1)
# => Thu, 01 Apr 2010 00:00:00 +0000
```

警告：由于`DateTime`不了解夏令时，您可能会在不存在的时间点上结束，而没有任何警告或错误告诉您。

注意：在`active_support/core_ext/date_time/calculations.rb`中定义。


#### 更改组件

方法[`change`][DateTime#change]允许您获取一个与接收器相同但给定选项不同的新日期时间，这些选项可以包括`：year`，`：month`，`：day`，`：hour`，`：min`，`：sec`，`：offset`，`：start`：

```ruby
now = DateTime.current
# => Tue, 08 Jun 2010 01:56:22 +0000
now.change(year: 2011, offset: Rational(-6, 24))
# => Wed, 08 Jun 2011 01:56:22 -0600
```
如果小时被归零，那么分钟和秒钟也会被归零（除非它们有给定的值）：

```ruby
now.change(hour: 0)
# => Tue, 08 Jun 2010 00:00:00 +0000
```

同样地，如果分钟被归零，那么秒钟也会被归零（除非它有给定的值）：

```ruby
now.change(min: 0)
# => Tue, 08 Jun 2010 01:00:00 +0000
```

如果更改无效，该方法不会容忍不存在的日期，会引发`ArgumentError`：

```ruby
DateTime.current.change(month: 2, day: 30)
# => ArgumentError: invalid date
```

注意：定义在`active_support/core_ext/date_time/calculations.rb`中。


#### 持续时间

可以将[`Duration`][ActiveSupport::Duration]对象添加到日期时间中或从日期时间中减去：

```ruby
now = DateTime.current
# => Mon, 09 Aug 2010 23:15:17 +0000
now + 1.year
# => Tue, 09 Aug 2011 23:15:17 +0000
now - 1.week
# => Mon, 02 Aug 2010 23:15:17 +0000
```

它们转换为对`since`或`advance`的调用。例如，在这里我们得到了正确的日历改革跳跃：

```ruby
DateTime.new(1582, 10, 4, 23) + 1.hour
# => Fri, 15 Oct 1582 00:00:00 +0000
```

`Time`的扩展
--------------------

### 计算

它们是类似的。请参考上面的文档，并考虑以下差异：

* [`change`][Time#change]接受一个额外的`:usec`选项。
* `Time`理解夏令时，因此您会得到正确的夏令时计算，如下所示：

```ruby
Time.zone_default
# => #<ActiveSupport::TimeZone:0x7f73654d4f38 @utc_offset=nil, @name="Madrid", ...>

# 在巴塞罗那，2010/03/28 02:00 +0100 由于夏令时变为 2010/03/28 03:00 +0200。
t = Time.local(2010, 3, 28, 1, 59, 59)
# => Sun Mar 28 01:59:59 +0100 2010
t.advance(seconds: 1)
# => Sun Mar 28 03:00:00 +0200 2010
```

* 如果[`since`][Time#since]或[`ago`][Time#ago]跳转到无法用`Time`表示的时间，将返回一个`DateTime`对象。


#### `Time.current`

Active Support定义了[`Time.current`][Time.current]为当前时区的今天。这类似于`Time.now`，但它遵守用户时区（如果定义）。它还定义了实例谓词[`past?`][DateAndTime::Calculations#past?]、[`today?`][DateAndTime::Calculations#today?]、[`tomorrow?`][DateAndTime::Calculations#tomorrow?]、[`next_day?`][DateAndTime::Calculations#next_day?]、[`yesterday?`][DateAndTime::Calculations#yesterday?]、[`prev_day?`][DateAndTime::Calculations#prev_day?]和[`future?`][DateAndTime::Calculations#future?]，它们都是相对于`Time.current`的。

在使用尊重用户时区的方法进行时间比较时，请确保使用`Time.current`而不是`Time.now`。有些情况下，用户时区可能比系统时区未来，而`Time.now`默认使用系统时区。这意味着`Time.now.to_date`可能等于`Date.yesterday`。

注意：定义在`active_support/core_ext/time/calculations.rb`中。


#### `all_day`、`all_week`、`all_month`、`all_quarter`和`all_year`

方法[`all_day`][DateAndTime::Calculations#all_day]返回表示当前时间整天的范围。

```ruby
now = Time.current
# => Mon, 09 Aug 2010 23:20:05 UTC +00:00
now.all_day
# => Mon, 09 Aug 2010 00:00:00 UTC +00:00..Mon, 09 Aug 2010 23:59:59 UTC +00:00
```

类似地，[`all_week`][DateAndTime::Calculations#all_week]、[`all_month`][DateAndTime::Calculations#all_month]、[`all_quarter`][DateAndTime::Calculations#all_quarter]和[`all_year`][DateAndTime::Calculations#all_year]都用于生成时间范围。

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

注意：定义在`active_support/core_ext/date_and_time/calculations.rb`中。


#### `prev_day`、`next_day`

[`prev_day`][Time#prev_day]和[`next_day`][Time#next_day]返回上一天或下一天的时间：

```ruby
t = Time.new(2010, 5, 8) # => 2010-05-08 00:00:00 +0900
t.prev_day               # => 2010-05-07 00:00:00 +0900
t.next_day               # => 2010-05-09 00:00:00 +0900
```

注意：定义在`active_support/core_ext/time/calculations.rb`中。


#### `prev_month`、`next_month`

[`prev_month`][Time#prev_month]和[`next_month`][Time#next_month]返回上个月或下个月的相同日期的时间：
```ruby
t = Time.new(2010, 5, 8) # => 2010-05-08 00:00:00 +0900
t.prev_month             # => 2010-04-08 00:00:00 +0900
t.next_month             # => 2010-06-08 00:00:00 +0900
```

如果这一天不存在，将返回对应月份的最后一天：

```ruby
Time.new(2000, 5, 31).prev_month # => 2000-04-30 00:00:00 +0900
Time.new(2000, 3, 31).prev_month # => 2000-02-29 00:00:00 +0900
Time.new(2000, 5, 31).next_month # => 2000-06-30 00:00:00 +0900
Time.new(2000, 1, 31).next_month # => 2000-02-29 00:00:00 +0900
```

注意：定义在 `active_support/core_ext/time/calculations.rb` 中。


#### `prev_year`, `next_year`

[`prev_year`][Time#prev_year] 和 [`next_year`][Time#next_year] 返回上一年或下一年的相同日期/月份的时间：

```ruby
t = Time.new(2010, 5, 8) # => 2010-05-08 00:00:00 +0900
t.prev_year              # => 2009-05-08 00:00:00 +0900
t.next_year              # => 2011-05-08 00:00:00 +0900
```

如果日期是闰年的2月29日，则返回28日：

```ruby
t = Time.new(2000, 2, 29) # => 2000-02-29 00:00:00 +0900
t.prev_year               # => 1999-02-28 00:00:00 +0900
t.next_year               # => 2001-02-28 00:00:00 +0900
```

注意：定义在 `active_support/core_ext/time/calculations.rb` 中。


#### `prev_quarter`, `next_quarter`

[`prev_quarter`][DateAndTime::Calculations#prev_quarter] 和 [`next_quarter`][DateAndTime::Calculations#next_quarter] 返回上一个或下一个季度的相同日期的时间：

```ruby
t = Time.local(2010, 5, 8) # => 2010-05-08 00:00:00 +0300
t.prev_quarter             # => 2010-02-08 00:00:00 +0200
t.next_quarter             # => 2010-08-08 00:00:00 +0300
```

如果这一天不存在，将返回对应月份的最后一天：

```ruby
Time.local(2000, 7, 31).prev_quarter  # => 2000-04-30 00:00:00 +0300
Time.local(2000, 5, 31).prev_quarter  # => 2000-02-29 00:00:00 +0200
Time.local(2000, 10, 31).prev_quarter # => 2000-07-31 00:00:00 +0300
Time.local(2000, 11, 31).next_quarter # => 2001-03-01 00:00:00 +0200
```

`prev_quarter` 的别名是 [`last_quarter`][DateAndTime::Calculations#last_quarter]。

注意：定义在 `active_support/core_ext/date_and_time/calculations.rb` 中。


### 时间构造函数

Active Support 定义了 [`Time.current`][Time.current]，如果有用户时区定义，则为 `Time.zone.now`，否则为 `Time.now`：

```ruby
Time.zone_default
# => #<ActiveSupport::TimeZone:0x7f73654d4f38 @utc_offset=nil, @name="Madrid", ...>
Time.current
# => Fri, 06 Aug 2010 17:11:58 CEST +02:00
```

类似于 `DateTime`，谓词 [`past?`][DateAndTime::Calculations#past?] 和 [`future?`][DateAndTime::Calculations#future?] 是相对于 `Time.current` 的。

如果要构造的时间超出运行时平台 `Time` 支持的范围，微秒将被丢弃，并返回一个 `DateTime` 对象。

#### 时长

可以将 [`Duration`][ActiveSupport::Duration] 对象添加到时间对象中或从时间对象中减去：

```ruby
now = Time.current
# => Mon, 09 Aug 2010 23:20:05 UTC +00:00
now + 1.year
# => Tue, 09 Aug 2011 23:21:11 UTC +00:00
now - 1.week
# => Mon, 02 Aug 2010 23:21:11 UTC +00:00
```

它们会转换为对 `since` 或 `advance` 的调用。例如，这里我们得到了正确的日历改革跳跃：

```ruby
Time.utc(1582, 10, 3) + 5.days
# => Mon Oct 18 00:00:00 UTC 1582
```

`File` 的扩展
--------------------

### `atomic_write`

使用类方法 [`File.atomic_write`][File.atomic_write] 可以以防止任何读取器看到半写内容的方式写入文件。

文件名作为参数传递，并且该方法会产生一个用于写入的文件句柄。一旦块完成，`atomic_write` 关闭文件句柄并完成其工作。

例如，Action Pack 使用此方法来写入资源缓存文件，如 `all.css`：

```ruby
File.atomic_write(joined_asset_path) do |cache|
  cache.write(join_asset_file_contents(asset_paths))
end
```

为了实现这一点，`atomic_write` 创建一个临时文件。这是块中的代码实际写入的文件。完成后，临时文件被重命名，这在 POSIX 系统上是一个原子操作。如果目标文件存在，`atomic_write` 会覆盖它并保留所有者和权限。然而，在某些情况下，`atomic_write` 无法更改文件的所有权或权限，此错误被捕获并跳过，相信用户/文件系统确保文件对需要它的进程可访问。

注意：由于 `atomic_write` 执行的 chmod 操作，如果目标文件上设置了 ACL，则此 ACL 将被重新计算/修改。
警告。请注意，您不能使用`atomic_write`进行追加。

辅助文件将写入一个标准的临时文件目录，但您可以将自定义目录作为第二个参数传递。

注意：在`active_support/core_ext/file/atomic.rb`中定义。

`NameError`的扩展
-------------------------

Active Support为`NameError`添加了[`missing_name?`][NameError#missing_name?]方法，用于测试异常是否是由于传递的名称引起的。

名称可以作为符号或字符串给出。符号与裸常量名称进行比较，字符串与完全限定的常量名称进行比较。

提示：符号可以表示完全限定的常量名称，例如`:"ActiveRecord::Base"`，因此对于符号的行为是为了方便起见而定义的，而不是因为技术上必须这样做。

例如，当调用`ArticlesController`的一个动作时，Rails会乐观地尝试使用`ArticlesHelper`。如果助手模块不存在，那么引发该常量名称的异常是可以接受的，因此应该将其静默处理。但是，可能存在这样一种情况，即`articles_helper.rb`由于实际未知的常量而引发了`NameError`。这种情况应该重新引发。`missing_name?`方法提供了一种区分这两种情况的方法：

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

注意：在`active_support/core_ext/name_error.rb`中定义。

`LoadError`的扩展
-------------------------

Active Support为`LoadError`添加了[`is_missing?`][LoadError#is_missing?]方法。

给定一个路径名，`is_missing?`方法测试异常是否是由于该特定文件引起的（除了可能的".rb"扩展名）。

例如，当调用`ArticlesController`的一个动作时，Rails会尝试加载`articles_helper.rb`，但该文件可能不存在。这是可以接受的，因为助手模块不是必需的，所以Rails会静默处理加载错误。但是，可能存在这样一种情况，即助手模块确实存在，并且反过来需要另一个缺失的库。在这种情况下，Rails必须重新引发异常。`is_missing?`方法提供了一种区分这两种情况的方法：

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

注意：在`active_support/core_ext/load_error.rb`中定义。

`Pathname`的扩展
-------------------------

### `existence`

[`existence`][Pathname#existence]方法如果指定的文件存在，则返回接收器，否则返回`nil`。这对于以下习惯用法很有用：

```ruby
content = Pathname.new("file").existence&.read
```

注意：在`active_support/core_ext/pathname/existence.rb`中定义。
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
