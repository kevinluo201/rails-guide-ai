**DO NOT READ THIS FILE ON GITHUB, GUIDES ARE PUBLISHED ON https://guides.rubyonrails.org.**, original file md5: 720efaf8e1845c472cc18a5e55f3eabb
Active Record加密
========================

本指南介绍了如何使用Active Record加密数据库信息。

阅读本指南后，您将了解以下内容：

* 如何使用Active Record设置数据库加密。
* 如何迁移未加密的数据。
* 如何使不同的加密方案共存。
* 如何使用API。
* 如何配置库以及如何扩展它。

--------------------------------------------------------------------------------

Active Record支持应用级加密。它通过声明应该加密哪些属性，并在必要时无缝加密和解密它们来工作。加密层位于数据库和应用程序之间。应用程序将访问未加密的数据，但数据库将存储加密的数据。

## 为什么在应用程序级别加密数据？

Active Record加密的存在是为了保护应用程序中的敏感信息。一个典型的例子是来自用户的个人身份信息。但是，如果您已经在休息时加密了数据库，为什么还需要应用程序级别的加密呢？

作为一个直接的实际好处，加密敏感属性会增加一个额外的安全层。例如，如果攻击者获得了您的数据库、快照或应用程序日志的访问权限，他们将无法理解加密的信息。此外，加密可以防止开发人员在应用程序日志中意外暴露用户的敏感数据。

但更重要的是，通过使用Active Record加密，您可以在代码级别定义应用程序中的敏感信息。Active Record加密使您能够对应用程序中的数据访问以及从应用程序中消耗数据的服务进行细粒度控制。例如，考虑到[保护加密数据的审计Rails控制台](https://github.com/basecamp/console1984)或检查内置系统以[自动过滤控制器参数](#filtering-params-named-as-encrypted-columns)。

## 基本用法

### 设置

首先，您需要向[Rails凭据](/security.html#custom-credentials)中添加一些密钥。运行`bin/rails db:encryption:init`生成一组随机密钥：

```bash
$ bin/rails db:encryption:init
将此条目添加到目标环境的凭据中：

active_record_encryption:
  primary_key: EGY8WhulUOXixybod7ZWwMIL68R9o5kC
  deterministic_key: aPA5XyALhf75NNnMzaspW7akTfZp0lPY
  key_derivation_salt: xEY0dt6TZcAMg52K7O84wYzkjvbA62Hz
```

注意：这些生成的值长度为32字节。如果您自己生成这些值，应该使用的最小长度为12字节的主密钥（这将用于派生AES 32字节密钥）和20字节的盐。

### 声明加密属性

加密属性在模型级别上进行定义。这些是由具有相同名称的列支持的常规Active Record属性。

```ruby
class Article < ApplicationRecord
  encrypts :title
end
````

库将在保存到数据库之前透明地加密这些属性，并在检索时解密它们：

```ruby
article = Article.create title: "Encrypt it all!"
article.title # => "Encrypt it all!"
```

但是，在底层执行的SQL如下所示：

```sql
INSERT INTO `articles` (`title`) VALUES ('{\"p\":\"n7J0/ol+a7DRMeaE\",\"h\":{\"iv\":\"DXZMDWUKfp3bg/Yu\",\"at\":\"X1/YjMHbHD4talgF9dt61A==\"}}')
```

#### 重要提示：关于存储和列大小

由于Base64编码和与加密有效负载一起存储的元数据，加密需要额外的空间。当使用内置的信封加密密钥提供程序时，您可以估计最坏情况下的开销约为255字节。这种开销在较大的大小下是可以忽略的。不仅因为它被稀释了，而且因为库默认使用压缩，对于较大的有效负载，可以提供高达30%的存储节省。

关于字符串列大小有一个重要的问题：在现代数据库中，列大小决定了它可以分配的*字符数*，而不是字节数。例如，使用UTF-8，每个字符最多可以占用四个字节，因此，潜在地，使用UTF-8的数据库中的列可以存储多达其大小的四倍的*字节数*。现在，加密有效负载是作为Base64序列化的二进制字符串存储的，因此它们可以存储在常规的`string`列中。因为它们是ASCII字节的序列，所以加密列可以最多占用其明文版本大小的四倍。因此，即使在数据库中存储的字节相同，列也必须大四倍。

实际上，这意味着：

* 当加密使用西方字母（主要是ASCII字符）编写的短文本时，您应该在定义列大小时考虑到这255个额外开销。
* 当加密使用非西方字母（例如西里尔字母）编写的短文本时，您应该将列大小乘以4。请注意，存储开销最多为255字节。
* 当加密长文本时，您可以忽略列大小的问题。
一些示例：

| 要加密的内容                                        | 原始列大小          | 推荐的加密列大小                 | 存储开销（最坏情况） |
| ------------------------------------------------- | -------------------- | --------------------------------- | ----------------------------- |
| 电子邮件地址                                      | string(255)          | string(510)                       | 255字节                      |
| 简短的表情序列                                    | string(255)          | string(1020)                      | 255字节                      |
| 用非西方字母写的文本摘要                           | string(500)          | string(2000)                      | 255字节                      |
| 任意长的文本                                      | text                 | text                              | 可忽略                        |

### 确定性和非确定性加密

默认情况下，Active Record Encryption使用非确定性加密方法。在这个上下文中，非确定性意味着使用相同的密码对相同的内容进行两次加密将得到不同的密文。这种方法通过增加密码分析的难度和使数据库查询变得不可能来提高安全性。

您可以使用`deterministic:`选项以确定性方式生成初始化向量，从而有效地启用对加密数据的查询。

```ruby
class Author < ApplicationRecord
  encrypts :email, deterministic: true
end

Author.find_by_email("some@email.com") # 您可以正常查询模型
```

非确定性方法是推荐的，除非您需要查询数据。

注意：在非确定性模式下，Active Record使用256位密钥和随机初始化向量的AES-GCM加密。在确定性模式下，它也使用AES-GCM，但初始化向量是由密钥和要加密的内容的HMAC-SHA-256摘要生成的。

注意：您可以通过省略`deterministic_key`来禁用确定性加密。

## 特性

### Action Text

您可以通过在声明中传递`encrypted: true`来加密Action Text属性。

```ruby
class Message < ApplicationRecord
  has_rich_text :content, encrypted: true
end
```

注意：目前不支持将单独的加密选项传递给Action Text属性。它将使用配置的全局加密选项进行非确定性加密。

### Fixture

您可以通过将以下选项添加到`test.rb`中，自动加密Rails Fixture：

```ruby
config.active_record.encryption.encrypt_fixtures = true
```

启用后，所有可加密的属性将根据模型中定义的加密设置进行加密。

#### Action Text Fixture

要加密Action Text Fixture，您应将其放置在`fixtures/action_text/encrypted_rich_texts.yml`中。

### 支持的类型

`active_record.encryption`将在加密之前使用底层类型对值进行序列化，但*它们必须可序列化为字符串*。支持结构化类型，如`serialized`。

如果您需要支持自定义类型，推荐的方法是使用[serialized attribute](https://api.rubyonrails.org/classes/ActiveRecord/AttributeMethods/Serialization/ClassMethods.html)。序列化属性的声明应在加密声明之前：

```ruby
# 正确
class Article < ApplicationRecord
  serialize :title, type: Title
  encrypts :title
end

# 错误
class Article < ApplicationRecord
  encrypts :title
  serialize :title, type: Title
end
```

### 忽略大小写

在查询确定性加密数据时，您可能需要忽略大小写。有两种方法可以更容易地实现这一点：

您可以在声明加密属性时使用`:downcase`选项，在加密之前将内容转换为小写。

```ruby
class Person
  encrypts :email_address, deterministic: true, downcase: true
end
```

使用`:downcase`时，原始大小写将丢失。在某些情况下，您可能希望仅在查询时忽略大小写，同时保留原始大小写。对于这些情况，您可以使用选项`:ignore_case`。这需要您添加一个名为`original_<column_name>`的新列，以存储保持大小写不变的内容：

```ruby
class Label
  encrypts :name, deterministic: true, ignore_case: true # 带有原始大小写的内容将存储在列`original_name`中
end
```

### 支持未加密数据

为了简化未加密数据的迁移，该库包括选项`config.active_record.encryption.support_unencrypted_data`。当设置为`true`时：

* 尝试读取未加密的属性将正常工作，不会引发任何错误。
* 具有确定性加密属性的查询将包括它们的“明文”版本，以支持查找加密和未加密内容。您需要设置`config.active_record.encryption.extend_queries = true`来启用此功能。

**此选项适用于过渡期间**，在此期间，明文数据和加密数据必须共存。默认情况下，两者都设置为`false`，这是任何应用程序的推荐目标：在使用未加密数据时将引发错误。

### 支持先前的加密方案

更改属性的加密属性可能会破坏现有数据。例如，假设您想将确定性属性更改为非确定性属性。如果只是更改模型中的声明，读取现有的密文将失败，因为加密方法现在不同。
为了支持这些情况，您可以声明将在两种情况下使用的先前加密方案：

* 在读取加密数据时，Active Record Encryption 将尝试先前的加密方案，如果当前方案不起作用。
* 在查询确定性数据时，它将使用先前的方案添加密文，以便查询可以无缝地与使用不同方案加密的数据一起工作。您必须设置 `config.active_record.encryption.extend_queries = true` 来启用此功能。

您可以配置先前的加密方案：

* 全局配置
* 按属性配置

#### 全局先前加密方案

您可以通过将它们作为属性列表添加到 `application.rb` 中的 `previous` 配置属性中来添加先前的加密方案：

```ruby
config.active_record.encryption.previous = [ { key_provider: MyOldKeyProvider.new } ]
```

#### 按属性加密方案

在声明属性时使用 `:previous`：

```ruby
class Article
  encrypts :title, deterministic: true, previous: { deterministic: false }
end
```

#### 加密方案和确定性属性

在添加先前的加密方案时：

* 对于**非确定性加密**，新信息将始终使用*最新*（当前）的加密方案进行加密。
* 对于**确定性加密**，新信息将默认始终使用*最旧*的加密方案进行加密。

通常，对于确定性加密，您希望密文保持不变。您可以通过设置 `deterministic: { fixed: false }` 来更改此行为。在这种情况下，它将使用*最新*的加密方案来加密新数据。

### 唯一约束

注意：唯一约束只能用于确定性加密的数据。

#### 唯一验证

只要启用了扩展查询（`config.active_record.encryption.extend_queries = true`），唯一验证就会正常工作。

```ruby
class Person
  validates :email_address, uniqueness: true
  encrypts :email_address, deterministic: true, downcase: true
end
```

当组合加密和非加密数据以及配置先前的加密方案时，它们也会起作用。

注意：如果要忽略大小写，请确保在 `encrypts` 声明中使用 `downcase:` 或 `ignore_case:`。在验证中使用 `case_sensitive:` 选项将不起作用。

#### 唯一索引

为了支持确定性加密列上的唯一索引，您需要确保其密文永远不会更改。

为了鼓励这一点，当配置了多个加密方案时，确定性属性默认始终使用最旧的可用加密方案。否则，您需要确保这些属性的加密属性不会更改，否则唯一索引将无法工作。

```ruby
class Person
  encrypts :email_address, deterministic: true
end
```

### 过滤以加密列命名的参数

默认情况下，加密列被配置为在 Rails 日志中[自动过滤](action_controller_overview.html#parameters-filtering)。您可以通过将以下内容添加到 `application.rb` 来禁用此行为：

生成过滤参数时，它将使用模型名称作为前缀。例如：对于 `Person#name`，过滤参数将是 `person.name`。

```ruby
config.active_record.encryption.add_to_filter_parameters = false
```

如果您想要从此自动过滤中排除特定列，请将它们添加到 `config.active_record.encryption.excluded_from_filter_parameters` 中。

### 编码

该库将保留非确定性加密的字符串值的编码。

由于编码与加密的有效负载一起存储，确定性加密的值默认会强制使用 UTF-8 编码。因此，具有不同编码的相同值在加密时会产生不同的密文。通常，您希望避免这种情况以保持查询和唯一性约束的工作，因此该库将自动为您执行转换。

您可以使用以下配置为确定性加密配置所需的默认编码：

```ruby
config.active_record.encryption.forced_encoding_for_deterministic_encryption = Encoding::US_ASCII
```

您还可以禁用此行为并在所有情况下保留编码：

```ruby
config.active_record.encryption.forced_encoding_for_deterministic_encryption = nil
```

## 密钥管理

密钥提供者实现密钥管理策略。您可以全局或按属性配置密钥提供者。

### 内置密钥提供者

#### DerivedSecretKeyProvider

这是一个密钥提供者，它将使用 PBKDF2 从提供的密码派生密钥。

```ruby
config.active_record.encryption.key_provider = ActiveRecord::Encryption::DerivedSecretKeyProvider.new(["some passwords", "to derive keys from. ", "These should be in", "credentials"])
```

注意：默认情况下，`active_record.encryption` 配置了一个 `DerivedSecretKeyProvider`，其中包含在凭据 `active_record.encryption.primary_key` 中定义的密钥。

#### EnvelopeEncryptionKeyProvider

实现了一个简单的[信封加密](https://docs.aws.amazon.com/kms/latest/developerguide/concepts.html#enveloping)策略：

- 它为每个数据加密操作生成一个随机密钥
- 它将数据密钥与数据本身一起存储，使用在凭据 `active_record.encryption.primary_key` 中定义的主密钥进行加密。

您可以通过将以下内容添加到 `application.rb` 中来配置 Active Record 使用此密钥提供者：

```ruby
config.active_record.encryption.key_provider = ActiveRecord::Encryption::EnvelopeEncryptionKeyProvider.new
```

与其他内置密钥提供者一样，您可以在 `active_record.encryption.primary_key` 中提供主密钥列表以实现密钥轮换方案。
### 自定义密钥提供者

对于更高级的密钥管理方案，您可以在初始化程序中配置自定义密钥提供者：

```ruby
ActiveRecord::Encryption.key_provider = MyKeyProvider.new
```

密钥提供者必须实现以下接口：

```ruby
class MyKeyProvider
  def encryption_key
  end

  def decryption_keys(encrypted_message)
  end
end
```

这两个方法都返回`ActiveRecord::Encryption::Key`对象：

- `encryption_key`返回用于加密某些内容的密钥
- `decryption_keys`返回用于解密给定消息的潜在密钥列表

密钥可以包含与消息一起以未加密方式存储的任意标签。您可以使用`ActiveRecord::Encryption::Message#headers`在解密时检查这些值。

### 模型特定的密钥提供者

您可以使用`:key_provider`选项在每个类上配置密钥提供者：

```ruby
class Article < ApplicationRecord
  encrypts :summary, key_provider: ArticleKeyProvider.new
end
```

### 模型特定的密钥

您可以使用`:key`选项在每个类上配置给定的密钥：

```ruby
class Article < ApplicationRecord
  encrypts :summary, key: "some secret key for article summaries"
end
```

Active Record使用该密钥来派生用于加密和解密数据的密钥。

### 密钥轮换

`active_record.encryption`可以使用密钥列表来支持实现密钥轮换方案：

- **最后一个密钥**将用于加密新内容。
- 在解密内容时，将尝试所有密钥，直到找到一个可用的密钥。

```yml
active_record_encryption:
  primary_key:
    - a1cc4d7b9f420e40a337b9e68c5ecec6 # 之前的密钥仍然可以解密现有内容
    - bc17e7b413fd4720716a7633027f8cc4 # 活动的，用于加密新内容
  key_derivation_salt: a3226b97b3b2f8372d1fc6d497a0c0d3
```

这使您可以通过添加新密钥、重新加密内容和删除旧密钥来保留一小组密钥的工作流程。

注意：目前不支持确定性加密的密钥轮换。

注意：Active Record Encryption尚未提供密钥轮换过程的自动管理。所有的组件都已经准备好了，但尚未实现。

### 存储密钥引用

您可以配置`active_record.encryption.store_key_references`，使`active_record.encryption`将对加密密钥的引用存储在加密消息本身中。

```ruby
config.active_record.encryption.store_key_references = true
```

这样做可以提高解密性能，因为系统现在可以直接定位密钥，而不是尝试密钥列表。付出的代价是存储空间：加密数据会稍微变大。

## API

### 基本API

ActiveRecord加密旨在以声明方式使用，但它提供了用于高级使用场景的API。

#### 加密和解密

```ruby
article.encrypt # 加密或重新加密所有可加密属性
article.decrypt # 解密所有可加密属性
```

#### 读取密文

```ruby
article.ciphertext_for(:title)
```

#### 检查属性是否已加密

```ruby
article.encrypted_attribute?(:title)
```

## 配置

### 配置选项

您可以在`application.rb`（最常见的情况）或特定环境配置文件`config/environments/<env name>.rb`中配置Active Record Encryption选项，如果您想要在每个环境上设置它们。

警告：建议使用Rails内置的凭据支持来存储密钥。如果您希望通过配置属性手动设置它们，请确保不要将它们与您的代码一起提交（例如使用环境变量）。

#### `config.active_record.encryption.support_unencrypted_data`

当为true时，可以正常读取未加密的数据。当为false时，将引发错误。默认值：`false`。

#### `config.active_record.encryption.extend_queries`

当为true时，将修改引用确定性加密属性的查询，以包括必要的附加值。这些附加值将是干净版本的值（当`config.active_record.encryption.support_unencrypted_data`为true时），以及以前的加密方案加密的值（使用`previous:`选项提供）。默认值：`false`（实验性）。

#### `config.active_record.encryption.encrypt_fixtures`

当为true时，加载fixture时，将自动加密fixture中的可加密属性。默认值：`false`。

#### `config.active_record.encryption.store_key_references`

当为true时，将密钥引用存储在加密消息的头部。这样可以加快解密速度，当使用多个密钥时。默认值：`false`。

#### `config.active_record.encryption.add_to_filter_parameters`

当为true时，加密属性名称将自动添加到[`config.filter_parameters`][]中，并且不会显示在日志中。默认值：`true`。

#### `config.active_record.encryption.excluded_from_filter_parameters`

您可以配置一个列表，当`config.active_record.encryption.add_to_filter_parameters`为true时，这些参数将不会被过滤掉。默认值：`[]`。

#### `config.active_record.encryption.validate_column_size`

基于列大小添加验证。这是为了防止使用高度可压缩的有效负载存储巨大的值。默认值：`true`。

#### `config.active_record.encryption.primary_key`

用于派生根数据加密密钥的密钥或密钥列表。它们的使用方式取决于配置的密钥提供者。最好通过`active_record_encryption.primary_key`凭据进行配置。
#### `config.active_record.encryption.deterministic_key`

用于确定性加密的密钥或密钥列表。最好通过`active_record_encryption.deterministic_key`凭据进行配置。

#### `config.active_record.encryption.key_derivation_salt`

在派生密钥时使用的盐。最好通过`active_record_encryption.key_derivation_salt`凭据进行配置。

#### `config.active_record.encryption.forced_encoding_for_deterministic_encryption`

确定性加密属性的默认编码。您可以通过将此选项设置为`nil`来禁用强制编码。默认为`Encoding::UTF_8`。

#### `config.active_record.encryption.hash_digest_class`

用于派生密钥的摘要算法。默认为`OpenSSL::Digest::SHA1`。

#### `config.active_record.encryption.support_sha1_for_non_deterministic_encryption`

支持使用SHA1摘要类对非确定性加密的数据进行解密。默认值为false，这意味着它只支持在`config.active_record.encryption.hash_digest_class`中配置的摘要算法。

### 加密上下文

加密上下文定义了在给定时刻使用的加密组件。根据全局配置，有一个默认的加密上下文，但您可以为特定属性或在运行特定代码块时配置自定义上下文。

注意：加密上下文是一种灵活但高级的配置机制。大多数用户不需要关心它们。

加密上下文的主要组件包括：

* `encryptor`：公开用于加密和解密数据的内部API。它与`key_provider`交互以构建加密消息并处理其序列化。加密/解密本身由`cipher`完成，序列化由`message_serializer`完成。
* `cipher`：加密算法本身（AES 256 GCM）
* `key_provider`：提供加密和解密密钥。
* `message_serializer`：序列化和反序列化加密的有效负载（`Message`）。

注意：如果您决定构建自己的`message_serializer`，重要的是使用不能反序列化任意对象的安全机制。一个常见的支持场景是加密现有的未加密数据。攻击者可以利用这一点，在加密之前输入篡改的有效负载并执行RCE攻击。这意味着自定义序列化器应避免使用`Marshal`，`YAML.load`（使用`YAML.safe_load`代替）或`JSON.load`（使用`JSON.parse`代替）。

#### 全局加密上下文

全局加密上下文是默认使用的上下文，并在`application.rb`或环境配置文件中配置为其他配置属性。

```ruby
config.active_record.encryption.key_provider = ActiveRecord::Encryption::EnvelopeEncryptionKeyProvider.new
config.active_record.encryption.encryptor = MyEncryptor.new
```

#### 每个属性的加密上下文

您可以通过在属性声明中传递它们来覆盖加密上下文参数：

```ruby
class Attribute
  encrypts :title, encryptor: MyAttributeEncryptor.new
end
```

#### 运行代码块时的加密上下文

您可以使用`ActiveRecord::Encryption.with_encryption_context`为给定的代码块设置加密上下文：

```ruby
ActiveRecord::Encryption.with_encryption_context(encryptor: ActiveRecord::Encryption::NullEncryptor.new) do
  ...
end
```

#### 内置加密上下文

##### 禁用加密

您可以在没有加密的情况下运行代码：

```ruby
ActiveRecord::Encryption.without_encryption do
   ...
end
```

这意味着读取加密文本将返回密文，并且保存的内容将以未加密的形式存储。

##### 保护加密数据

您可以在没有加密的情况下运行代码，但防止覆盖加密内容：

```ruby
ActiveRecord::Encryption.protecting_encrypted_data do
   ...
end
```

如果您想在仍然对其运行任意代码的同时保护加密数据（例如在Rails控制台中），这可能很方便。
[`config.filter_parameters`]: configuring.html#config-filter-parameters
