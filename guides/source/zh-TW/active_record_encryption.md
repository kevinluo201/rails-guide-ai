**DO NOT READ THIS FILE ON GITHUB, GUIDES ARE PUBLISHED ON https://guides.rubyonrails.org.**, original file md5: 720efaf8e1845c472cc18a5e55f3eabb
Active Record 加密
========================

本指南介紹了如何使用 Active Record 加密數據庫信息。

閱讀完本指南後，您將了解：

* 如何使用 Active Record 設置數據庫加密。
* 如何遷移未加密數據。
* 如何使不同的加密方案共存。
* 如何使用 API。
* 如何配置庫並擴展它。

--------------------------------------------------------------------------------

Active Record 支持應用程序級加密。它通過聲明哪些屬性應該被加密，並在必要時無縫加密和解密它們來工作。加密層位於數據庫和應用程序之間。應用程序將訪問未加密的數據，但數據庫將存儲加密的數據。

## 為什麼要在應用程序級別加密數據？

Active Record 加密的存在是為了保護應用程序中的敏感信息。一個典型的例子是來自用戶的可識別信息。但是，如果您已經在休息時加密數據庫，為什麼還需要應用程序級別的加密呢？

作為一個即時的實際好處，加密敏感屬性增加了一個額外的安全層。例如，如果攻擊者獲得了您的數據庫、快照或應用程序日誌，他們將無法理解加密的信息。此外，加密可以防止開發人員在應用程序日誌中意外暴露用戶的敏感數據。

但更重要的是，通過使用 Active Record 加密，您可以在代碼級別上定義應用程序中的敏感信息。Active Record 加密使您能夠對應用程序中的數據訪問以及從應用程序中消費數據的服務進行細粒度控制。例如，考慮到[保護加密數據的可審計的 Rails 控制台](https://github.com/basecamp/console1984)或檢查內置系統以[自動過濾控制器參數](#filtering-params-named-as-encrypted-columns)。

## 基本用法

### 設置

首先，您需要將一些密鑰添加到您的[Rails 憑據](/security.html#custom-credentials)中。運行 `bin/rails db:encryption:init` 生成一組隨機密鑰：

```bash
$ bin/rails db:encryption:init
將此條目添加到目標環境的憑據中：

active_record_encryption:
  primary_key: EGY8WhulUOXixybod7ZWwMIL68R9o5kC
  deterministic_key: aPA5XyALhf75NNnMzaspW7akTfZp0lPY
  key_derivation_salt: xEY0dt6TZcAMg52K7O84wYzkjvbA62Hz
```

注意：這些生成的值長度為 32 字節。如果您自己生成這些值，您應該使用的最小長度為 12 字節的主密鑰（這將用於派生 AES 32 字節密鑰）和 20 字節的鹽。

### 声明加密屬性

加密屬性在模型級別上進行定義。這些是由具有相同名稱的列支持的常規 Active Record 屬性。

```ruby
class Article < ApplicationRecord
  encrypts :title
end
````

庫將在保存到數據庫之前對這些屬性進行透明加密，並在檢索時對其進行解密：

```ruby
article = Article.create title: "Encrypt it all!"
article.title # => "Encrypt it all!"
```

但是，在內部，執行的 SQL 如下所示：

```sql
INSERT INTO `articles` (`title`) VALUES ('{\"p\":\"n7J0/ol+a7DRMeaE\",\"h\":{\"iv\":\"DXZMDWUKfp3bg/Yu\",\"at\":\"X1/YjMHbHD4talgF9dt61A==\"}}')
```

#### 重要提示：關於存儲和列大小

由於 Base64 編碼和與加密有效負載一起存儲的元數據，加密需要額外的空間。當使用內置的信封加密密鑰提供程序時，您可以估計最壞情況下的開銷約為 255 字節。在較大的大小下，這種開銷是可以忽略的。不僅因為它被稀釋了，而且因為庫默認使用壓縮，對於較大的有效負載，可以提供高達 30% 的存儲節省。

有關字符串列大小的一個重要問題：在現代數據庫中，列大小確定了它可以分配的*字符數*，而不是字節數。例如，使用 UTF-8，每個字符最多可以占用四個字節，因此，潛在地，使用 UTF-8 的數據庫中的列可以根據*字節數*的大小存儲多達四倍的大小。現在，加密有效負載是序列化為 Base64 的二進制字符串，因此它們可以存儲在常規的 `string` 列中。因為它們是一系列 ASCII 字節，所以加密列的大小可以達到其明文版本大小的四倍。因此，即使在數據庫中存儲的字節相同，列的大小也必須增加四倍。

在實踐中，這意味著：

* 當加密西方字母（主要是 ASCII 字符）的短文本時，您應該在定義列大小時考慮到這 255 個額外的開銷。
* 當加密使用非西方字母（例如西里爾字母）的短文本時，您應該將列大小乘以 4。請注意，存儲開銷最多為 255 字節。
* 當加密長文本時，您可以忽略列大小的問題。
一些例子：

| 要加密的內容                                       | 原始欄位大小         | 建議的加密欄位大小               | 儲存空間開銷（最壞情況） |
| ------------------------------------------------- | -------------------- | --------------------------------- | ----------------------------- |
| 電子郵件地址                                     | string(255)          | string(510)                       | 255 bytes                     |
| 簡短的表情符號序列                               | string(255)          | string(1020)                      | 255 bytes                     |
| 以非西方字母書寫的文本摘要                         | string(500)          | string(2000)                      | 255 bytes                     |
| 任意長的文本                                     | text                 | text                              | 可忽略不計                     |

### 確定性和非確定性加密

預設情況下，Active Record Encryption 使用非確定性方法進行加密。在這個上下文中，非確定性意味著使用相同的密碼對相同的內容進行兩次加密會得到不同的密文。這種方法通過使密文的密碼分析更加困難，並且無法查詢數據庫來提高安全性。

您可以使用 `deterministic:` 選項以確定性方式生成初始化向量，從而有效地啟用對加密數據的查詢。

```ruby
class Author < ApplicationRecord
  encrypts :email, deterministic: true
end

Author.find_by_email("some@email.com") # 您可以正常查詢模型
```

除非您需要查詢數據，否則建議使用非確定性方法。

注意：在非確定性模式下，Active Record 使用具有256位密鑰和隨機初始化向量的AES-GCM。在確定性模式下，它也使用AES-GCM，但初始化向量是由密鑰和要加密的內容的HMAC-SHA-256摘要生成的。

注意：您可以通過省略 `deterministic_key` 來禁用確定性加密。

## 功能

### Action Text

您可以通過在聲明中傳遞 `encrypted: true` 來加密 Action Text 屬性。

```ruby
class Message < ApplicationRecord
  has_rich_text :content, encrypted: true
end
```

注意：目前不支持將個別的加密選項傳遞給 Action Text 屬性。它將使用配置的全局加密選項進行非確定性加密。

### 測試數據

您可以通過將以下選項添加到 `test.rb` 中，自動對 Rails 測試數據進行加密：

```ruby
config.active_record.encryption.encrypt_fixtures = true
```

啟用後，所有可加密的屬性將根據模型中定義的加密設置進行加密。

#### Action Text 測試數據

要加密 Action Text 測試數據，您應將其放置在 `fixtures/action_text/encrypted_rich_texts.yml` 中。

### 支持的類型

`active_record.encryption` 將在加密之前使用底層類型對值進行序列化，但它們必須可序列化為字符串。支持直接的類型，如 `serialized`。

如果您需要支持自定義類型，建議的方法是使用[序列化屬性](https://api.rubyonrails.org/classes/ActiveRecord/AttributeMethods/Serialization/ClassMethods.html)。序列化屬性的聲明應該在加密聲明之前：

```ruby
# 正確
class Article < ApplicationRecord
  serialize :title, type: Title
  encrypts :title
end

# 不正確
class Article < ApplicationRecord
  encrypts :title
  serialize :title, type: Title
end
```

### 忽略大小寫

在查詢確定性加密數據時，您可能需要忽略大小寫。有兩種方法可以更容易地實現這一點：

您可以在聲明加密屬性時使用 `:downcase` 選項，在加密之前將內容轉換為小寫。

```ruby
class Person
  encrypts :email_address, deterministic: true, downcase: true
end
```

使用 `:downcase` 選項時，原始大小寫將丟失。在某些情況下，您可能希望只在查詢時忽略大小寫，同時保留原始大小寫。對於這些情況，您可以使用 `:ignore_case` 選項。這需要您添加一個名為 `original_<column_name>` 的新列，以存儲保持大小寫不變的內容：

```ruby
class Label
  encrypts :name, deterministic: true, ignore_case: true # 帶有原始大小寫的內容將存儲在列 `original_name` 中
end
```

### 支持未加密數據

為了方便遷移未加密數據，庫包括了選項 `config.active_record.encryption.support_unencrypted_data`。當設置為 `true` 時：

* 嘗試讀取未加密的屬性將正常工作，不會引發任何錯誤。
* 具有確定性加密屬性的查詢將包含它們的 "明文" 版本，以支持查找加密和未加密內容。您需要將 `config.active_record.encryption.extend_queries = true` 設置為啟用此功能。

**此選項旨在在過渡期間使用**，在此期間清晰數據和加密數據必須共存。默認情況下，兩者都設置為 `false`，這是任何應用程序的推薦目標：在使用未加密數據時將引發錯誤。
為了支援這些情況，您可以聲明在兩種情境中將使用的先前加密方案：

* 在讀取加密數據時，Active Record Encryption 將嘗試先前的加密方案，如果當前方案無法運作。
* 在查詢確定性數據時，它將使用先前的方案添加密文，以便查詢與使用不同方案加密的數據無縫運作。您必須設置 `config.active_record.encryption.extend_queries = true` 來啟用此功能。

您可以配置先前的加密方案：

* 全局配置
* 按屬性配置

#### 全局先前加密方案

您可以通過將它們作為屬性列表添加到 `application.rb` 中的 `previous` 配置屬性中來添加先前的加密方案：

```ruby
config.active_record.encryption.previous = [ { key_provider: MyOldKeyProvider.new } ]
```

#### 按屬性加密方案

在聲明屬性時使用 `:previous`：

```ruby
class Article
  encrypts :title, deterministic: true, previous: { deterministic: false }
end
```

#### 加密方案和確定性屬性

在添加先前的加密方案時：

* 對於**非確定性加密**，新信息將始終使用*最新*（當前）的加密方案進行加密。
* 對於**確定性加密**，新信息將始終使用默認情況下的*最舊*的加密方案進行加密。

通常，對於確定性加密，您希望密文保持不變。您可以通過設置 `deterministic: { fixed: false }` 來更改此行為。在這種情況下，它將使用*最新*的加密方案來加密新數據。

### 唯一約束

注意：唯一約束只能用於確定性加密的數據。

#### 唯一驗證

只要啟用了擴展查詢（`config.active_record.encryption.extend_queries = true`），唯一驗證就可以正常工作。

```ruby
class Person
  validates :email_address, uniqueness: true
  encrypts :email_address, deterministic: true, downcase: true
end
```

它們也可以在結合加密和非加密數據以及配置先前加密方案時正常工作。

注意：如果您想忽略大小寫，請確保在 `encrypts` 聲明中使用 `downcase:` 或 `ignore_case:`。在驗證中使用 `case_sensitive:` 選項將不起作用。

#### 唯一索引

為了支援確定性加密列上的唯一索引，您需要確保它們的密文永遠不會改變。

為了鼓勵這一點，當配置了多個加密方案時，確定性屬性默認情況下將始終使用最舊的可用加密方案。否則，您需要確保這些屬性的加密屬性不會改變，否則唯一索引將無法工作。

```ruby
class Person
  encrypts :email_address, deterministic: true
end
```

### 將加密列名稱作為過濾參數

默認情況下，加密列被配置為在 Rails 日誌中[自動過濾](action_controller_overview.html#parameters-filtering)。您可以通過將以下內容添加到 `application.rb` 中來禁用此行為：

生成過濾參數時，它將使用模型名稱作為前綴。例如：對於 `Person#name`，過濾參數將是 `person.name`。

```ruby
config.active_record.encryption.add_to_filter_parameters = false
```

如果您想要從此自動過濾中排除特定列，將它們添加到 `config.active_record.encryption.excluded_from_filter_parameters` 中。

### 編碼

該庫將保留非確定性加密的字符串值的編碼。

因為編碼與加密的有效負載一起存儲，所以確定性加密的值默認情況下將強制使用 UTF-8 編碼。因此，具有不同編碼的相同值在加密時將產生不同的密文。通常，您希望避免這種情況以保持查詢和唯一性約束的正常工作，因此該庫將自動為您執行轉換。

您可以使用以下配置為確定性加密配置所需的默認編碼：

```ruby
config.active_record.encryption.forced_encoding_for_deterministic_encryption = Encoding::US_ASCII
```

您也可以禁用此行為並在所有情況下保留編碼：

```ruby
config.active_record.encryption.forced_encoding_for_deterministic_encryption = nil
```

## 金鑰管理

金鑰提供者實現金鑰管理策略。您可以全局配置金鑰提供者，或按屬性配置。

### 內建金鑰提供者

#### DerivedSecretKeyProvider

一個將從提供的密碼使用 PBKDF2 派生金鑰的金鑰提供者。

```ruby
config.active_record.encryption.key_provider = ActiveRecord::Encryption::DerivedSecretKeyProvider.new(["some passwords", "to derive keys from. ", "These should be in", "credentials"])
```

注意：默認情況下，`active_record.encryption` 配置了一個 `DerivedSecretKeyProvider`，其中包含在凭證 `active_record.encryption.primary_key` 中定義的金鑰。

#### EnvelopeEncryptionKeyProvider

實現一個簡單的 [信封加密](https://docs.aws.amazon.com/kms/latest/developerguide/concepts.html#enveloping) 策略：

- 它為每個數據加密操作生成一個隨機金鑰
- 它將數據金鑰與數據本身一起存儲，並使用在凭證 `active_record.encryption.primary_key` 中定義的主金鑰進行加密。

您可以通過將以下內容添加到 `application.rb` 中來配置 Active Record 使用此金鑰提供者：

```ruby
config.active_record.encryption.key_provider = ActiveRecord::Encryption::EnvelopeEncryptionKeyProvider.new
```

與其他內建金鑰提供者一樣，您可以在 `active_record.encryption.primary_key` 中提供主金鑰列表，以實現金鑰輪換策略。
### 自訂金鑰提供者

對於更高級的金鑰管理方案，您可以在初始化程序中配置自訂金鑰提供者：

```ruby
ActiveRecord::Encryption.key_provider = MyKeyProvider.new
```

金鑰提供者必須實現以下介面：

```ruby
class MyKeyProvider
  def encryption_key
  end

  def decryption_keys(encrypted_message)
  end
end
```

這兩個方法都返回 `ActiveRecord::Encryption::Key` 對象：

- `encryption_key` 返回用於加密某些內容的金鑰
- `decryption_keys` 返回解密給定消息的潛在金鑰列表

金鑰可以包含與消息一起未加密存儲的任意標籤。在解密時，您可以使用 `ActiveRecord::Encryption::Message#headers` 檢查這些值。

### 模型特定的金鑰提供者

您可以使用 `:key_provider` 選項在每個類上配置金鑰提供者：

```ruby
class Article < ApplicationRecord
  encrypts :summary, key_provider: ArticleKeyProvider.new
end
```

### 模型特定的金鑰

您可以使用 `:key` 選項在每個類上配置給定的金鑰：

```ruby
class Article < ApplicationRecord
  encrypts :summary, key: "some secret key for article summaries"
end
```

Active Record 使用該金鑰來派生用於加密和解密數據的金鑰。

### 旋轉金鑰

`active_record.encryption` 可以使用金鑰列表來支持實現金鑰旋轉方案：

- **最後一個金鑰** 將用於加密新內容。
- 解密內容時，將嘗試所有金鑰，直到找到一個可用的金鑰。

```yml
active_record_encryption:
  primary_key:
    - a1cc4d7b9f420e40a337b9e68c5ecec6 # 之前的金鑰仍然可以解密現有內容
    - bc17e7b413fd4720716a7633027f8cc4 # 現用金鑰，用於加密新內容
  key_derivation_salt: a3226b97b3b2f8372d1fc6d497a0c0d3
```

這使您可以通過添加新金鑰、重新加密內容並刪除舊金鑰來保留一個短金鑰列表。

注意：當前不支持對稱加密的金鑰旋轉。

注意：Active Record Encryption 尚未提供金鑰旋轉流程的自動管理。所有必要的組件都已經存在，但尚未實現。

### 存儲金鑰引用

您可以配置 `active_record.encryption.store_key_references` 以使 `active_record.encryption` 在加密的消息本身中存儲對金鑰的引用。

```ruby
config.active_record.encryption.store_key_references = true
```

這樣做可以提高解密的性能，因為系統現在可以直接定位金鑰，而不是嘗試金鑰列表。代價是存儲：加密數據會稍微變大。

## API

### 基本 API

ActiveRecord 加密旨在以聲明方式使用，但它提供了一個用於高級使用場景的 API。

#### 加密和解密

```ruby
article.encrypt # 加密或重新加密所有可加密的屬性
article.decrypt # 解密所有可加密的屬性
```

#### 讀取密文

```ruby
article.ciphertext_for(:title)
```

#### 檢查屬性是否已加密

```ruby
article.encrypted_attribute?(:title)
```

## 配置

### 配置選項

您可以在 `application.rb`（最常見的情況）或特定環境配置文件 `config/environments/<env name>.rb` 中配置 Active Record Encryption 選項，如果您希望在每個環境上設置它們。

警告：建議使用 Rails 內置的憑證支持來存儲金鑰。如果您選擇通過配置屬性手動設置它們，請確保不要將它們與代碼一起提交（例如使用環境變量）。

#### `config.active_record.encryption.support_unencrypted_data`

當為 true 時，可以正常讀取未加密的數據。當為 false 時，將引發錯誤。默認值：`false`。

#### `config.active_record.encryption.extend_queries`

當為 true 時，將修改引用具有確定性加密屬性的查詢，以包括必要的附加值。這些附加值將是該值的清晰版本（當 `config.active_record.encryption.support_unencrypted_data` 為 true 時），以及以前的加密方案加密的值（使用 `previous:` 選項提供）。默認值：`false`（實驗性的）。

#### `config.active_record.encryption.encrypt_fixtures`

當為 true 時，加載時將自動加密夾具中的可加密屬性。默認值：`false`。

#### `config.active_record.encryption.store_key_references`

當為 true 時，將金鑰引用存儲在加密消息的標頭中。這樣做可以加快解密速度，當使用多個金鑰時。默認值：`false`。

#### `config.active_record.encryption.add_to_filter_parameters`

當為 true 時，加密的屬性名稱將自動添加到 [`config.filter_parameters`][] 中，並且不會顯示在日誌中。默認值：`true`。

#### `config.active_record.encryption.excluded_from_filter_parameters`

您可以配置一個列表，當 `config.active_record.encryption.add_to_filter_parameters` 為 true 時，這些參數將不會被過濾掉。默認值：`[]`。

#### `config.active_record.encryption.validate_column_size`

基於列大小的驗證。這是為了防止使用高度可壓縮有效載荷存儲巨大的值。默認值：`true`。

#### `config.active_record.encryption.primary_key`

用於派生根數據加密金鑰的金鑰或金鑰列表。它們的使用方式取決於配置的金鑰提供者。最好通過 `active_record_encryption.primary_key` 憑證進行配置。
#### `config.active_record.encryption.deterministic_key`

用於確定性加密的金鑰或金鑰列表。最好通過 `active_record_encryption.deterministic_key` 憑證進行配置。

#### `config.active_record.encryption.key_derivation_salt`

在派生金鑰時使用的鹽。最好通過 `active_record_encryption.key_derivation_salt` 憑證進行配置。

#### `config.active_record.encryption.forced_encoding_for_deterministic_encryption`

用於確定性加密的屬性的默認編碼。您可以通過將此選項設置為 `nil` 來禁用強制編碼。默認為 `Encoding::UTF_8`。

#### `config.active_record.encryption.hash_digest_class`

用於派生金鑰的摘要算法。默認為 `OpenSSL::Digest::SHA1`。

#### `config.active_record.encryption.support_sha1_for_non_deterministic_encryption`

支持使用 SHA1 摘要類加密的非確定性加密數據的解密。默認為 false，這意味著它只支持在 `config.active_record.encryption.hash_digest_class` 中配置的摘要算法。

### 加密上下文

加密上下文定義了在給定時刻使用的加密組件。根據全局配置，有一個默認的加密上下文，但您可以為特定屬性或在運行特定代碼塊時配置自定義上下文。

注意：加密上下文是一種靈活但高級的配置機制。大多數用戶不需要關心它們。

加密上下文的主要組件包括：

* `encryptor`：公開用於加密和解密數據的內部 API。它與 `key_provider` 交互以構建加密消息並處理其序列化。加密/解密本身由 `cipher` 執行，序列化由 `message_serializer` 執行。
* `cipher`：加密算法本身（AES 256 GCM）
* `key_provider`：提供加密和解密金鑰。
* `message_serializer`：序列化和反序列化加密的有效負載（`Message`）。

注意：如果您決定構建自己的 `message_serializer`，重要的是使用不能反序列化任意對象的安全機制。一個常見的支持場景是加密現有的未加密數據。攻擊者可以利用這一點，在加密之前輸入篡改的有效負載並執行 RCE 攻擊。這意味著自定義序列化器應該避免使用 `Marshal`、`YAML.load`（使用 `YAML.safe_load` 替代）或 `JSON.load`（使用 `JSON.parse` 替代）。

#### 全局加密上下文

全局加密上下文是默認使用的上下文，並在您的 `application.rb` 或環境配置文件中配置為其他配置屬性。

```ruby
config.active_record.encryption.key_provider = ActiveRecord::Encryption::EnvelopeEncryptionKeyProvider.new
config.active_record.encryption.encryptor = MyEncryptor.new
```

#### 每個屬性的加密上下文

您可以通過在屬性聲明中傳遞它們來覆蓋加密上下文參數：

```ruby
class Attribute
  encrypts :title, encryptor: MyAttributeEncryptor.new
end
```

#### 在運行代碼塊時的加密上下文

您可以使用 `ActiveRecord::Encryption.with_encryption_context` 為給定的代碼塊設置加密上下文：

```ruby
ActiveRecord::Encryption.with_encryption_context(encryptor: ActiveRecord::Encryption::NullEncryptor.new) do
  ...
end
```

#### 內置的加密上下文

##### 禁用加密

您可以在不加密的情況下運行代碼：

```ruby
ActiveRecord::Encryption.without_encryption do
   ...
end
```

這意味著讀取加密文本將返回密文，並且保存的內容將以未加密的形式存儲。

##### 保護加密數據

您可以在不加密的情況下運行代碼，但防止覆蓋加密內容：

```ruby
ActiveRecord::Encryption.protecting_encrypted_data do
   ...
end
```

這在您希望在運行任意代碼（例如在 Rails 控制台中）時保護加密數據時非常有用。
[`config.filter_parameters`]: configuring.html#config-filter-parameters
