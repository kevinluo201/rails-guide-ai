**DO NOT READ THIS FILE ON GITHUB, GUIDES ARE PUBLISHED ON https://guides.rubyonrails.org.**, original file md5: 720efaf8e1845c472cc18a5e55f3eabb
Active Record 암호화
========================

이 가이드는 Active Record를 사용하여 데이터베이스 정보를 암호화하는 방법을 다룹니다.

이 가이드를 읽은 후에는 다음을 알게 됩니다:

* Active Record를 사용하여 데이터베이스 암호화를 설정하는 방법.
* 암호화되지 않은 데이터를 마이그레이션하는 방법.
* 다른 암호화 방식을 공존시키는 방법.
* API를 사용하는 방법.
* 라이브러리를 구성하는 방법 및 확장하는 방법.

--------------------------------------------------------------------------------

Active Record는 응용 프로그램 수준의 암호화를 지원합니다. 필요할 때 암호화 및 복호화를 자동으로 수행하도록 속성을 선언하여 작동합니다. 암호화 계층은 데이터베이스와 응용 프로그램 사이에 위치합니다. 응용 프로그램은 암호화되지 않은 데이터에 액세스하지만 데이터베이스는 암호화된 상태로 저장합니다.

## 응용 프로그램 수준에서 데이터를 왜 암호화해야 하나요?

Active Record 암호화는 응용 프로그램에서 민감한 정보를 보호하기 위해 존재합니다. 전형적인 예는 사용자의 개인 식별 정보입니다. 그러나 이미 데이터베이스를 안전하게 암호화하고 있다면 왜 응용 프로그램 수준에서 암호화를 원할까요?

즉각적인 실용적인 이점으로, 민감한 속성을 암호화하면 추가적인 보안 계층이 추가됩니다. 예를 들어, 공격자가 데이터베이스, 데이터베이스 스냅샷 또는 응용 프로그램 로그에 액세스한 경우, 암호화된 정보를 해석할 수 없습니다. 또한, 암호화는 응용 프로그램 로그에서 사용자의 민감한 데이터가 무심코 노출되는 것을 방지할 수 있습니다.

그러나 더 중요한 것은 Active Record 암호화를 사용하여 응용 프로그램 코드 수준에서 민감한 정보가 무엇인지 정의할 수 있다는 것입니다. Active Record 암호화를 사용하면 응용 프로그램에서 데이터에 대한 데이터 액세스를 세밀하게 제어할 수 있으며, 응용 프로그램에서 데이터를 사용하는 서비스도 마찬가지입니다. 예를 들어, [암호화된 데이터를 보호하는 auditable Rails 콘솔](https://github.com/basecamp/console1984)이나 [자동으로 컨트롤러 매개변수를 필터링하는 내장 시스템](#filtering-params-named-as-encrypted-columns)을 고려해보세요.

## 기본 사용법

### 설정

먼저, [Rails 자격 증명](/security.html#custom-credentials)에 일부 키를 추가해야 합니다. `bin/rails db:encryption:init`을 실행하여 무작위 키 세트를 생성하세요:

```bash
$ bin/rails db:encryption:init
다음 항목을 대상 환경의 자격 증명에 추가하세요:

active_record_encryption:
  primary_key: EGY8WhulUOXixybod7ZWwMIL68R9o5kC
  deterministic_key: aPA5XyALhf75NNnMzaspW7akTfZp0lPY
  key_derivation_salt: xEY0dt6TZcAMg52K7O84wYzkjvbA62Hz
```

참고: 생성된 값은 길이가 32바이트입니다. 직접 생성하는 경우, 최소 길이는 기본 키에 대해 12바이트(이는 AES 32바이트 키를 유도하는 데 사용됨) 및 솔트에 대해 20바이트여야 합니다.

### 암호화된 속성 선언

암호화 가능한 속성은 모델 수준에서 정의됩니다. 이는 동일한 이름을 가진 열을 지원하는 일반적인 Active Record 속성입니다.

```ruby
class Article < ApplicationRecord
  encrypts :title
end
````

라이브러리는 이러한 속성을 데이터베이스에 저장하기 전에 투명하게 암호화하고, 검색 시에는 복호화합니다:

```ruby
article = Article.create title: "Encrypt it all!"
article.title # => "Encrypt it all!"
```

그러나 내부적으로 실행되는 SQL은 다음과 같습니다:

```sql
INSERT INTO `articles` (`title`) VALUES ('{\"p\":\"n7J0/ol+a7DRMeaE\",\"h\":{\"iv\":\"DXZMDWUKfp3bg/Yu\",\"at\":\"X1/YjMHbHD4talgF9dt61A==\"}}')
```

#### 중요: 저장 및 열 크기에 대해

암호화는 Base64 인코딩 및 암호화된 페이로드와 함께 저장된 메타데이터 때문에 추가 공간이 필요합니다. 내장된 봉투 암호화 키 제공자를 사용할 때, 최악의 경우 오버헤드는 약 255바이트입니다. 이 오버헤드는 큰 크기에서는 무시할 만큼 작습니다. 그 이유는 희석되기 때문이고, 라이브러리가 기본적으로 압축을 사용하기 때문에 큰 페이로드의 경우 암호화되지 않은 버전에 비해 최대 30%의 저장 공간을 절약할 수 있습니다.

문자열 열 크기에 대한 중요한 고려 사항이 있습니다: 현대적인 데이터베이스에서 열 크기는 *문자 수*를 할당할 수 있는 것을 결정합니다. 예를 들어, UTF-8을 사용하는 데이터베이스의 경우 각 문자는 최대 4바이트를 차지할 수 있으므로, UTF-8을 사용하는 데이터베이스의 열은 *바이트 수*로서 크기의 최대 4배까지 저장할 수 있습니다. 이제 암호화된 페이로드는 Base64로 직렬화된 이진 문자열이므로 일반적인 `string` 열에 저장할 수 있습니다. ASCII 바이트의 시퀀스이기 때문에 암호화된 열은 명확한 버전 크기의 최대 4배까지 차지할 수 있습니다. 따라서 데이터베이스에 저장된 바이트가 동일하더라도 열은 4배 더 커야 합니다.

실제로는 다음과 같습니다:

* 서양 문자(주로 ASCII 문자)로 작성된 짧은 텍스트를 암호화하는 경우, 열 크기를 정의할 때 해당 255 추가 오버헤드를 고려해야 합니다.
* 키릴 문자와 같은 서양 문자가 아닌 문자로 작성된 짧은 텍스트를 암호화하는 경우, 열 크기를 4배로 곱해야 합니다. 저장 공간 오버헤드는 최대 255바이트입니다.
* 긴 텍스트를 암호화하는 경우, 열 크기에 대한 고려 사항은 무시할 수 있습니다.
일부 예시:

| 암호화할 내용                                | 원래 열 크기 | 권장 암호화된 열 크기 | 저장 공간 오버헤드 (최악의 경우) |
| ------------------------------------------- | ------------ | --------------------- | ----------------------------- |
| 이메일 주소                                 | string(255)  | string(510)           | 255 바이트                     |
| 이모티콘의 짧은 시퀀스                       | string(255)  | string(1020)          | 255 바이트                     |
| 비서언어로 작성된 텍스트 요약                | string(500)  | string(2000)          | 255 바이트                     |
| 임의의 긴 텍스트                             | text         | text                   | 무시 가능                       |

### 결정적 및 비결정적 암호화

기본적으로 Active Record Encryption은 암호화에 비결정적인 접근 방식을 사용합니다. 이 맥락에서 비결정적이란 동일한 비밀번호로 동일한 내용을 두 번 암호화하면 다른 암호문이 생성된다는 것을 의미합니다. 이 접근 방식은 암호문의 암호 분석을 어렵게 만들고 데이터베이스에서의 쿼리를 불가능하게 하는 것으로 보안을 향상시킵니다.

암호화된 데이터를 쿼리할 수 있도록 초기화 벡터를 결정적으로 생성하기 위해 `deterministic:` 옵션을 사용할 수 있습니다.

```ruby
class Author < ApplicationRecord
  encrypts :email, deterministic: true
end

Author.find_by_email("some@email.com") # 모델을 정상적으로 쿼리할 수 있습니다.
```

쿼리할 데이터가 필요하지 않은 한 비결정적인 접근 방식을 권장합니다.

참고: 비결정적 모드에서 Active Record는 AES-GCM을 사용하며 256비트 키와 무작위 초기화 벡터를 사용합니다. 결정적 모드에서도 AES-GCM을 사용하지만 초기화 벡터는 키와 암호화할 내용의 HMAC-SHA-256 다이제스트로 생성됩니다.

참고: `deterministic_key`를 생략하여 결정적 암호화를 비활성화할 수 있습니다.

## 기능

### Action Text

`encrypted: true`를 선언에 전달하여 Action Text 속성을 암호화할 수 있습니다.

```ruby
class Message < ApplicationRecord
  has_rich_text :content, encrypted: true
end
```

참고: Action Text 속성에 개별 암호화 옵션을 전달하는 것은 아직 지원되지 않습니다. 전역 암호화 옵션으로 비결정적 암호화가 사용됩니다.

### 픽스처

`test.rb`에 다음 옵션을 추가하여 Rails 픽스처를 자동으로 암호화할 수 있습니다.

```ruby
config.active_record.encryption.encrypt_fixtures = true
```

활성화되면 모든 암호화 가능한 속성은 모델에서 정의된 암호화 설정에 따라 암호화됩니다.

#### Action Text 픽스처

Action Text 픽스처를 암호화하려면 `fixtures/action_text/encrypted_rich_texts.yml`에 배치해야 합니다.

### 지원되는 유형

`active_record.encryption`은 값들을 암호화하기 전에 내부 유형을 직렬화합니다. 그러나 *문자열로 직렬화될 수 있어야 합니다*. `serialized`와 같은 구조화된 유형은 기본적으로 지원됩니다.

사용자 정의 유형을 지원해야 하는 경우, 권장하는 방법은 [직렬화 속성](https://api.rubyonrails.org/classes/ActiveRecord/AttributeMethods/Serialization/ClassMethods.html)을 사용하는 것입니다. 직렬화된 속성의 선언은 암호화 선언 **앞에** 있어야 합니다.

```ruby
# 올바른 예
class Article < ApplicationRecord
  serialize :title, type: Title
  encrypts :title
end

# 잘못된 예
class Article < ApplicationRecord
  encrypts :title
  serialize :title, type: Title
end
```

### 대소문자 무시

결정적으로 암호화된 데이터를 쿼리할 때 대소문자를 무시해야 할 수도 있습니다. 이를 쉽게 수행하기 위해 두 가지 접근 방식을 사용할 수 있습니다:

암호화된 속성을 선언할 때 `:downcase` 옵션을 사용하여 암호화 전에 내용을 소문자로 변환할 수 있습니다.

```ruby
class Person
  encrypts :email_address, deterministic: true, downcase: true
end
```

`:downcase`를 사용하면 원래 대소문자 정보가 손실됩니다. 일부 상황에서는 쿼리할 때만 대소문자를 무시하고 원래 대소문자 정보를 유지하고 싶을 수 있습니다. 이러한 경우 `:ignore_case` 옵션을 사용할 수 있습니다. 이를 위해 `original_<column_name>`이라는 새로운 열을 추가하여 원래 대소문자 정보를 저장해야 합니다:

```ruby
class Label
  encrypts :name, deterministic: true, ignore_case: true # 원래 대소문자 정보는 `original_name` 열에 저장됩니다.
end
```

### 암호화되지 않은 데이터 지원

암호화되지 않은 데이터의 마이그레이션을 용이하게 하기 위해 라이브러리에는 `config.active_record.encryption.support_unencrypted_data` 옵션이 포함되어 있습니다. `true`로 설정하면:

* 암호화되지 않은 속성을 읽으려고 할 때 오류를 발생시키지 않고 정상적으로 작동합니다.
* 결정적으로 암호화된 속성을 사용하는 쿼리에는 암호화되지 않은 내용의 "클리어 텍스트" 버전이 포함되어 암호화된 내용과 암호화되지 않은 내용을 모두 찾을 수 있습니다. 이를 활성화하려면 `config.active_record.encryption.extend_queries = true`로 설정해야 합니다.

**이 옵션은 클리어 데이터와 암호화된 데이터가 공존해야 하는 전환 기간 동안 사용됩니다.** 기본적으로 둘 다 `false`로 설정되어 있으며, 이는 모든 애플리케이션에 권장되는 목표입니다. 암호화되지 않은 데이터를 처리할 때 오류가 발생합니다.

### 이전 암호화 방식 지원

속성의 암호화 속성을 변경하면 기존 데이터가 손상될 수 있습니다. 예를 들어, 결정적인 속성을 비결정적으로 변경하려는 경우 모델에서 선언을 변경하면 기존 암호문을 읽을 수 없으므로 읽기 작업이 실패합니다.
이러한 상황을 지원하기 위해 두 가지 시나리오에서 사용할 이전 암호화 방식을 선언할 수 있습니다.

* 암호화된 데이터를 읽을 때, Active Record Encryption은 현재 방식이 작동하지 않는 경우 이전 암호화 방식을 시도합니다.
* 결정론적 데이터를 쿼리할 때, 이전 방식을 사용하여 암호문을 추가하여 다른 방식으로 암호화된 데이터와 원활하게 작동하도록 합니다. 이를 활성화하려면 `config.active_record.encryption.extend_queries = true`를 설정해야 합니다.

이전 암호화 방식을 구성할 수 있습니다:

* 전역적으로
* 속성별로

#### 전역 이전 암호화 방식

`application.rb`에서 `previous` 구성 속성을 사용하여 속성 목록으로 추가하여 이전 암호화 방식을 추가할 수 있습니다:

```ruby
config.active_record.encryption.previous = [ { key_provider: MyOldKeyProvider.new } ]
```

#### 속성별 암호화 방식

속성을 선언할 때 `:previous`를 사용합니다:

```ruby
class Article
  encrypts :title, deterministic: true, previous: { deterministic: false }
end
```

#### 암호화 방식과 결정론적 속성

이전 암호화 방식을 추가할 때:

* **결정론적 암호화**의 경우, 새로운 정보는 항상 *최신* (현재) 암호화 방식으로 암호화됩니다.
* **결정론적 암호화**의 경우, 새로운 정보는 기본적으로 항상 *가장 오래된* 암호화 방식으로 암호화됩니다.

일반적으로 결정론적 암호화에서는 암호문이 일정하게 유지되기를 원합니다. `deterministic: { fixed: false }`를 설정하여 이 동작을 변경할 수 있습니다. 이 경우, 새 데이터를 암호화하기 위해 *최신* 암호화 방식을 사용합니다.

### 고유 제약 조건

참고: 고유 제약 조건은 결정론적으로 암호화된 데이터에만 사용할 수 있습니다.

#### 고유 유효성 검사

확장된 쿼리가 활성화되어 있는 경우 (`config.active_record.encryption.extend_queries = true`), 고유 유효성 검사는 일반적으로 지원됩니다.

```ruby
class Person
  validates :email_address, uniqueness: true
  encrypts :email_address, deterministic: true, downcase: true
end
```

암호화된 및 암호화되지 않은 데이터를 결합하거나 이전 암호화 방식을 구성한 경우에도 작동합니다.

참고: 대소문자를 무시하려면 `encrypts` 선언에서 `downcase:` 또는 `ignore_case:`를 사용해야 합니다. 유효성 검사에서 `case_sensitive:` 옵션을 사용하면 작동하지 않습니다.

#### 고유 인덱스

결정론적으로 암호화된 열에 대한 고유 인덱스를 지원하려면, 암호문이 절대로 변경되지 않도록 해야 합니다.

이를 위해 결정론적 속성은 여러 암호화 방식이 구성된 경우 기본적으로 가장 오래된 사용 가능한 암호화 방식을 사용합니다. 그렇지 않으면 이러한 속성에 대한 암호화 속성이 변경되지 않도록 해야 하며, 그렇지 않으면 고유 인덱스가 작동하지 않습니다.

```ruby
class Person
  encrypts :email_address, deterministic: true
end
```

### 암호화된 열로 이름이 지정된 필터링 매개변수

기본적으로 암호화된 열은 [Rails 로그에서 자동으로 필터링됩니다](action_controller_overview.html#parameters-filtering). 이 동작을 비활성화하려면 다음을 `application.rb`에 추가하십시오:

필터링 매개변수를 생성할 때, 모델 이름을 접두사로 사용합니다. 예: `Person#name`의 필터링 매개변수는 `person.name`입니다.

```ruby
config.active_record.encryption.add_to_filter_parameters = false
```

이 자동 필터링에서 특정 열을 제외하려면 `config.active_record.encryption.excluded_from_filter_parameters`에 추가하십시오.

### 인코딩

결정론적으로 암호화되지 않은 문자열 값의 인코딩은 유지됩니다.

인코딩은 암호화된 페이로드와 함께 저장되므로, 결정론적으로 암호화된 값은 기본적으로 UTF-8 인코딩을 강제합니다. 따라서 다른 인코딩을 가진 동일한 값은 암호화할 때 다른 암호문이 생성됩니다. 쿼리와 고유성 제약 조건이 작동하도록 하기 위해 이를 피하는 것이 일반적이므로, 라이브러리는 자동으로 변환 작업을 수행합니다.

결정론적 암호화에 대한 기본 인코딩을 구성할 수 있습니다:

```ruby
config.active_record.encryption.forced_encoding_for_deterministic_encryption = Encoding::US_ASCII
```

이 동작을 비활성화하고 모든 경우에 인코딩을 유지하려면 다음을 설정하십시오:

```ruby
config.active_record.encryption.forced_encoding_for_deterministic_encryption = nil
```

## 키 관리

키 제공자는 키 관리 전략을 구현합니다. 키 제공자를 전역적으로 또는 속성별로 구성할 수 있습니다.

### 내장된 키 제공자

#### DerivedSecretKeyProvider

PBKDF2를 사용하여 제공된 비밀번호에서 파생된 키를 제공하는 키 제공자입니다.

```ruby
config.active_record.encryption.key_provider = ActiveRecord::Encryption::DerivedSecretKeyProvider.new(["some passwords", "to derive keys from. ", "These should be in", "credentials"])
```

참고: 기본적으로 `active_record.encryption`은 `active_record.encryption.primary_key`에 정의된 키로 `DerivedSecretKeyProvider`를 구성합니다.

#### EnvelopeEncryptionKeyProvider

간단한 [봉투 암호화](https://docs.aws.amazon.com/kms/latest/developerguide/concepts.html#enveloping) 전략을 구현합니다:

- 각 데이터 암호화 작업에 대해 무작위 키를 생성합니다.
- 데이터 키를 데이터 자체와 함께 저장하며, 암호화된 기본 키로 암호화합니다. 이는 자격 증명 `active_record.encryption.primary_key`에 정의됩니다.

Active Record가 이 키 제공자를 사용하도록 `application.rb`에 다음을 추가하십시오:

```ruby
config.active_record.encryption.key_provider = ActiveRecord::Encryption::EnvelopeEncryptionKeyProvider.new
```

다른 내장 키 제공자와 마찬가지로, `active_record.encryption.primary_key`에 기본 키 목록을 제공하여 키 회전 계획을 구현할 수 있습니다.
### 사용자 정의 키 제공자

고급 키 관리 체계를 위해 초기화기에서 사용자 정의 키 제공자를 구성할 수 있습니다:

```ruby
ActiveRecord::Encryption.key_provider = MyKeyProvider.new
```

키 제공자는 다음 인터페이스를 구현해야 합니다:

```ruby
class MyKeyProvider
  def encryption_key
  end

  def decryption_keys(encrypted_message)
  end
end
```

두 메서드는 `ActiveRecord::Encryption::Key` 객체를 반환합니다:

- `encryption_key`는 일부 콘텐츠를 암호화하는 데 사용되는 키를 반환합니다.
- `decryption_keys`는 주어진 메시지를 복호화하는 데 사용할 수 있는 키 목록을 반환합니다.

키는 메시지와 함께 암호화되지 않은 상태로 저장되는 임의의 태그를 포함할 수 있습니다. 복호화할 때 해당 값을 검사하기 위해 `ActiveRecord::Encryption::Message#headers`를 사용할 수 있습니다.

### 모델별 키 제공자

`:key_provider` 옵션을 사용하여 클래스별로 키 제공자를 구성할 수 있습니다:

```ruby
class Article < ApplicationRecord
  encrypts :summary, key_provider: ArticleKeyProvider.new
end
```

### 모델별 키

`:key` 옵션을 사용하여 특정 키를 클래스별로 구성할 수 있습니다:

```ruby
class Article < ApplicationRecord
  encrypts :summary, key: "some secret key for article summaries"
end
```

Active Record는 데이터를 암호화하고 복호화하는 데 사용되는 키를 파생하기 위해 이 키를 사용합니다.

### 키 회전

`active_record.encryption`은 키 회전 체계를 구현하기 위해 키 목록과 함께 작동할 수 있습니다:

- **마지막 키**는 새로운 콘텐츠를 암호화하는 데 사용됩니다.
- 모든 키는 콘텐츠를 복호화할 때 하나가 작동할 때까지 시도됩니다.

```yml
active_record_encryption:
  primary_key:
    - a1cc4d7b9f420e40a337b9e68c5ecec6 # 이전 키는 여전히 기존 콘텐츠를 복호화할 수 있습니다.
    - bc17e7b413fd4720716a7633027f8cc4 # 활성화되어 있으며 새로운 콘텐츠를 암호화합니다.
  key_derivation_salt: a3226b97b3b2f8372d1fc6d497a0c0d3
```

이를 통해 새로운 키를 추가하고 콘텐츠를 다시 암호화하고 이전 키를 삭제하여 키 목록을 유지하는 워크플로우를 구현할 수 있습니다.

참고: 결정론적 암호화에 대해서는 현재 키 회전을 지원하지 않습니다.

참고: Active Record Encryption은 아직 키 회전 프로세스의 자동 관리를 제공하지 않습니다. 필요한 모든 구성 요소는 제공되지만 아직 구현되지 않았습니다.

### 키 참조 저장

`active_record.encryption.store_key_references`를 구성하여 `active_record.encryption`이 암호화된 메시지 자체에 암호화 키에 대한 참조를 저장하도록 설정할 수 있습니다.

```ruby
config.active_record.encryption.store_key_references = true
```

이렇게 하면 시스템이 키 목록을 시도하는 대신 키를 직접 찾을 수 있으므로 복호화 속도가 향상됩니다. 그러나 저장 공간이 증가하므로 암호화된 데이터가 약간 더 커집니다.

## API

### 기본 API

ActiveRecord 암호화는 선언적으로 사용되도록 설계되었지만, 고급 사용 시나리오를 위한 API를 제공합니다.

#### 암호화 및 복호화

```ruby
article.encrypt # 암호화 또는 다시 암호화 가능한 속성을 모두 암호화합니다.
article.decrypt # 모든 암호화된 속성을 복호화합니다.
```

#### 암호문 읽기

```ruby
article.ciphertext_for(:title)
```

#### 속성이 암호화되었는지 확인

```ruby
article.encrypted_attribute?(:title)
```

## 구성

### 구성 옵션

Active Record Encryption 옵션을 `application.rb` (가장 일반적인 시나리오) 또는 특정 환경 구성 파일 `config/environments/<env name>.rb`에서 구성할 수 있습니다.

경고: 키를 저장하기 위해 Rails 내장 자격 증명 지원을 사용하는 것이 좋습니다. 구성 속성을 수동으로 설정하려는 경우 코드와 함께 커밋하지 않도록 주의하십시오 (예: 환경 변수 사용).

#### `config.active_record.encryption.support_unencrypted_data`

참일 경우, 암호화되지 않은 데이터를 일반적으로 읽을 수 있습니다. 거짓일 경우 오류가 발생합니다. 기본값: `false`.

#### `config.active_record.encryption.extend_queries`

참일 경우, 결정론적으로 암호화된 속성을 참조하는 쿼리가 필요한 경우 추가 값이 포함되도록 수정됩니다. 이러한 추가 값은 값의 클린 버전 (`config.active_record.encryption.support_unencrypted_data`가 true인 경우) 및 이전 암호화 체계로 암호화된 값 (옵션으로 제공된대로 `previous:`)일 수 있습니다. 기본값: `false` (실험적).

#### `config.active_record.encryption.encrypt_fixtures`

참일 경우, 픽스처의 암호화 가능한 속성은 로드될 때 자동으로 암호화됩니다. 기본값: `false`.

#### `config.active_record.encryption.store_key_references`

참일 경우, 암호화된 메시지의 헤더에 암호화 키에 대한 참조가 저장됩니다. 이를 통해 여러 키를 사용할 때 더 빠른 복호화가 가능해집니다. 기본값: `false`.

#### `config.active_record.encryption.add_to_filter_parameters`

참일 경우, 암호화된 속성 이름이 자동으로 [`config.filter_parameters`][]에 추가되어 로그에 표시되지 않습니다. 기본값: `true`.


#### `config.active_record.encryption.excluded_from_filter_parameters`

`config.active_record.encryption.add_to_filter_parameters`가 true인 경우 필터링되지 않을 매개변수 목록을 구성할 수 있습니다. 기본값: `[]`.

#### `config.active_record.encryption.validate_column_size`

열 크기를 기반으로하는 유효성 검사를 추가합니다. 이는 매우 압축 가능한 페이로드를 사용하여 거대한 값을 저장하는 것을 방지하기 위해 권장됩니다. 기본값: `true`.

#### `config.active_record.encryption.primary_key`

루트 데이터 암호화 키를 파생하기 위해 사용되는 키 또는 키 목록입니다. 사용 방법은 구성된 키 제공자에 따라 다릅니다. `active_record_encryption.primary_key` 자격 증명으로 구성하는 것이 좋습니다.
#### `config.active_record.encryption.deterministic_key`

결정적 암호화에 사용되는 키 또는 키 목록입니다. `active_record_encryption.deterministic_key` 자격 증명을 통해 구성하는 것이 좋습니다.

#### `config.active_record.encryption.key_derivation_salt`

키를 파생할 때 사용되는 솔트입니다. `active_record_encryption.key_derivation_salt` 자격 증명을 통해 구성하는 것이 좋습니다.

#### `config.active_record.encryption.forced_encoding_for_deterministic_encryption`

결정적으로 암호화된 속성의 기본 인코딩입니다. 이 옵션을 `nil`로 설정하여 강제 인코딩을 비활성화할 수 있습니다. 기본값은 `Encoding::UTF_8`입니다.

#### `config.active_record.encryption.hash_digest_class`

키를 파생하기 위해 사용되는 다이제스트 알고리즘입니다. 기본값은 `OpenSSL::Digest::SHA1`입니다.

#### `config.active_record.encryption.support_sha1_for_non_deterministic_encryption`

SHA1 다이제스트 클래스로 비결정적으로 암호화된 데이터를 복호화하는 것을 지원합니다. 기본값은 false이며, 이는 `config.active_record.encryption.hash_digest_class`에서 구성된 다이제스트 알고리즘만 지원한다는 것을 의미합니다.

### 암호화 컨텍스트

암호화 컨텍스트는 주어진 순간에 사용되는 암호화 구성 요소를 정의합니다. 전역 구성에 기반한 기본 암호화 컨텍스트가 있지만, 특정 속성이나 특정 코드 블록을 실행할 때 사용자 정의 컨텍스트를 구성할 수 있습니다.

참고: 암호화 컨텍스트는 유연하지만 고급 구성 메커니즘입니다. 대부분의 사용자는 이에 대해 신경 쓸 필요가 없습니다.

암호화 컨텍스트의 주요 구성 요소는 다음과 같습니다.

* `encryptor`: 데이터를 암호화하고 복호화하기 위한 내부 API를 노출합니다. `key_provider`와 상호 작용하여 암호화된 메시지를 구축하고 직렬화 처리합니다. 암호화/복호화 자체는 `cipher`에 의해 수행되고 직렬화는 `message_serializer`에 의해 수행됩니다.
* `cipher`: 암호화 알고리즘 자체 (AES 256 GCM)
* `key_provider`: 암호화 및 복호화 키를 제공합니다.
* `message_serializer`: 암호화된 페이로드 (`Message`)를 직렬화하고 역직렬화합니다.

참고: 사용자 정의 `message_serializer`를 작성하기로 결정한 경우, 임의의 객체를 역직렬화할 수 없는 안전한 메커니즘을 사용하는 것이 중요합니다. 일반적으로 지원되는 시나리오는 기존의 암호화되지 않은 데이터를 암호화하는 것입니다. 공격자는 이를 이용하여 암호화가 진행되기 전에 조작된 페이로드를 입력하고 RCE(원격 코드 실행) 공격을 수행할 수 있습니다. 따라서 사용자 정의 직렬화기는 `Marshal`, `YAML.load` (대신 `YAML.safe_load` 사용), 또는 `JSON.load` (대신 `JSON.parse` 사용)를 피해야 합니다.

#### 전역 암호화 컨텍스트

전역 암호화 컨텍스트는 기본적으로 사용되는 컨텍스트로, `application.rb` 또는 환경 구성 파일에서 다른 구성 속성과 마찬가지로 구성됩니다.

```ruby
config.active_record.encryption.key_provider = ActiveRecord::Encryption::EnvelopeEncryptionKeyProvider.new
config.active_record.encryption.encryptor = MyEncryptor.new
```

#### 속성별 암호화 컨텍스트

속성 선언에서 컨텍스트 매개변수를 전달하여 암호화 컨텍스트 매개변수를 재정의할 수 있습니다.

```ruby
class Attribute
  encrypts :title, encryptor: MyAttributeEncryptor.new
end
```

#### 코드 블록 실행 시 암호화 컨텍스트

`ActiveRecord::Encryption.with_encryption_context`를 사용하여 주어진 코드 블록에 대한 암호화 컨텍스트를 설정할 수 있습니다.

```ruby
ActiveRecord::Encryption.with_encryption_context(encryptor: ActiveRecord::Encryption::NullEncryptor.new) do
  ...
end
```

#### 내장된 암호화 컨텍스트

##### 암호화 비활성화

암호화 없이 코드를 실행할 수 있습니다.

```ruby
ActiveRecord::Encryption.without_encryption do
   ...
end
```

이는 암호화된 텍스트를 읽으면 암호문이 반환되고, 저장된 내용은 암호화되지 않은 상태로 저장됩니다.

##### 암호화된 데이터 보호

암호화 없이 코드를 실행하지만 암호화된 내용을 덮어쓰지 않도록 방지할 수 있습니다.

```ruby
ActiveRecord::Encryption.protecting_encrypted_data do
   ...
end
```

이는 암호화된 데이터를 보호하면서 임의의 코드를 실행할 수 있는 경우에 유용할 수 있습니다(예: Rails 콘솔에서).
[`config.filter_parameters`]: configuring.html#config-filter-parameters
