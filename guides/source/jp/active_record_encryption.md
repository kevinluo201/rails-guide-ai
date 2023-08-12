**DO NOT READ THIS FILE ON GITHUB, GUIDES ARE PUBLISHED ON https://guides.rubyonrails.org.**, original file md5: 720efaf8e1845c472cc18a5e55f3eabb
Active Recordの暗号化
========================

このガイドでは、Active Recordを使用してデータベース情報を暗号化する方法について説明します。

このガイドを読み終えると、以下のことがわかります。

* Active Recordを使用してデータベースの暗号化を設定する方法。
* 暗号化されていないデータを移行する方法。
* 異なる暗号化方式を共存させる方法。
* APIの使用方法。
* ライブラリの設定方法と拡張方法。

--------------------------------------------------------------------------------

Active Recordは、アプリケーションレベルの暗号化をサポートしています。これは、どの属性を暗号化するかを宣言し、必要に応じて透過的に暗号化および復号化することによって機能します。暗号化レイヤーはデータベースとアプリケーションの間に存在し、アプリケーションは暗号化されていないデータにアクセスしますが、データベースは暗号化されたデータを保存します。

## アプリケーションレベルでデータを暗号化する理由

Active Record Encryptionは、アプリケーション内の機密情報を保護するために存在します。典型的な例は、ユーザーからの個人を特定できる情報です。しかし、既にデータベースを暗号化している場合、なぜアプリケーションレベルでの暗号化が必要なのでしょうか？

まず、実用的な利点として、機密属性を暗号化することで、追加のセキュリティレイヤーが追加されます。たとえば、攻撃者がデータベース、そのスナップショット、またはアプリケーションログにアクセスした場合、暗号化された情報を理解することはできません。さらに、暗号化は、開発者がアプリケーションログでユーザーの機密データを意図せずに公開することを防ぐことができます。

しかし、もっと重要なのは、Active Record Encryptionを使用することで、アプリケーションのコードレベルでどの情報が機密情報であるかを定義できることです。Active Record Encryptionにより、アプリケーション内のデータアクセスと、アプリケーションからデータを消費するサービスの細かい制御が可能になります。たとえば、[暗号化されたデータを保護する監査可能なRailsコンソール](https://github.com/basecamp/console1984)を考えてみるか、[コントローラーパラメータを自動的にフィルタリングする組み込みシステム](#filtering-params-named-as-encrypted-columns)をチェックしてください。

## 基本的な使用方法

### セットアップ

まず、[Railsのcredentials](/security.html#custom-credentials)にいくつかのキーを追加する必要があります。ランダムなキーセットを生成するには、`bin/rails db:encryption:init`を実行します。

```bash
$ bin/rails db:encryption:init
このエントリを対象環境のcredentialsに追加してください：

active_record_encryption:
  primary_key: EGY8WhulUOXixybod7ZWwMIL68R9o5kC
  deterministic_key: aPA5XyALhf75NNnMzaspW7akTfZp0lPY
  key_derivation_salt: xEY0dt6TZcAMg52K7O84wYzkjvbA62Hz
```

注意：これらの生成された値は32バイトの長さです。自分で生成する場合、最小の長さは主キーに12バイト（これはAES 32バイトキーを派生させるために使用されます）およびソルトに20バイトです。

### 暗号化属性の宣言

暗号化可能な属性は、モデルレベルで定義されます。これらは、同じ名前のカラムでバックアップされた通常のActive Record属性です。

```ruby
class Article < ApplicationRecord
  encrypts :title
end
````

ライブラリは、これらの属性をデータベースに保存する前に透過的に暗号化し、取得時に復号化します。

```ruby
article = Article.create title: "すべてを暗号化！"
article.title # => "すべてを暗号化！"
```

しかし、内部では、実行されるSQLは次のようになります。

```sql
INSERT INTO `articles` (`title`) VALUES ('{\"p\":\"n7J0/ol+a7DRMeaE\",\"h\":{\"iv\":\"DXZMDWUKfp3bg/Yu\",\"at\":\"X1/YjMHbHD4talgF9dt61A==\"}}')
```

#### 重要：ストレージとカラムサイズについて

暗号化には、Base64エンコーディングと暗号化ペイロードと一緒に保存されるメタデータのための余分なスペースが必要です。組み込みの暗号化キープロバイダを使用する場合、最悪の場合のオーバーヘッドは約255バイトと見積もることができます。このオーバーヘッドは、大きなサイズでは無視できるほどです。なぜなら、それが希釈されるだけでなく、ライブラリがデフォルトで圧縮を使用しているため、大きなペイロードの場合には非暗号化バージョンに比べて最大30%のストレージ節約が得られるからです。

文字列のカラムサイズに関する重要な懸念があります。現代のデータベースでは、カラムサイズは*文字数*を割り当てることができる数を決定します。たとえば、UTF-8を使用する場合、各文字は最大4バイトを占有するため、UTF-8を使用するデータベースのカラムは、*バイト数*の観点からはサイズの4倍まで格納できます。さて、暗号化されたペイロードはBase64でシリアライズされたバイナリ文字列ですので、通常の`string`カラムに格納することができます。ASCIIバイトのシーケンスであるため、暗号化されたカラムはクリアバージョンのサイズの4倍まで占有することができます。したがって、データベースに格納されるバイトが同じであっても、カラムは4倍大きくなる必要があります。

実際には、次のことを意味します。

* 西洋のアルファベット（主にASCII文字）で書かれた短いテキストを暗号化する場合は、カラムサイズを定義する際にこの255の追加オーバーヘッドを考慮する必要があります。
* キリル文字などの西洋以外のアルファベットで書かれた短いテキストを暗号化する場合は、カラムサイズを4倍にする必要があります。ストレージオーバーヘッドは最大で255バイトです。
* 長いテキストを暗号化する場合は、カラムサイズの懸念は無視できます。
いくつかの例：

| 暗号化するコンテンツ                                | 元の列のサイズ | 推奨される暗号化された列のサイズ | ストレージのオーバーヘッド（最悪の場合） |
| ------------------------------------------------- | -------------------- | --------------------------------- | ----------------------------- |
| メールアドレス                                   | string(255)          | string(510)                       | 255 バイト                     |
| 絵文字の短いシーケンス                          | string(255)          | string(1020)                      | 255 バイト                     |
| 非西洋文字で書かれたテキストの要約 | string(500)          | string(2000)                      | 255 バイト                     |
| 任意の長いテキスト                               | text                 | text                              | 無視できる程度                    |

### 決定論的暗号化と非決定論的暗号化

デフォルトでは、Active Record Encryptionは非決定論的なアプローチを使用して暗号化を行います。非決定論的とは、同じパスワードで同じコンテンツを2回暗号化すると、異なる暗号文が生成されることを意味します。このアプローチは、暗号文の暗号解読を困難にし、データベースのクエリを不可能にすることでセキュリティを向上させます。

`deterministic:` オプションを使用して、初期化ベクトルを決定論的に生成することで、暗号化されたデータのクエリを有効にすることができます。

```ruby
class Author < ApplicationRecord
  encrypts :email, deterministic: true
end

Author.find_by_email("some@email.com") # 通常通りモデルをクエリできます
```

データをクエリする必要がない場合は、非決定論的なアプローチが推奨されます。

注意：非決定論的モードでは、Active RecordはAES-GCMを使用し、256ビットのキーとランダムな初期化ベクトルを使用します。決定論的モードでは、AES-GCMも使用しますが、初期化ベクトルはキーと暗号化するコンテンツのHMAC-SHA-256ダイジェストとして生成されます。

注意：`deterministic_key`を省略することで、決定論的暗号化を無効にすることができます。

## 機能

### Action Text

Action Text属性を暗号化するには、宣言で `encrypted: true` を渡すことができます。

```ruby
class Message < ApplicationRecord
  has_rich_text :content, encrypted: true
end
```

注意：Action Text属性に個別の暗号化オプションを渡すことはまだサポートされていません。グローバルな暗号化オプションが設定された非決定論的な暗号化が使用されます。

### フィクスチャ

`test.rb` にこのオプションを追加することで、Railsのフィクスチャを自動的に暗号化することができます。

```ruby
config.active_record.encryption.encrypt_fixtures = true
```

有効にすると、すべての暗号化可能な属性は、モデルで定義された暗号化設定に従って暗号化されます。

#### Action Textのフィクスチャ

Action Textのフィクスチャを暗号化するには、`fixtures/action_text/encrypted_rich_texts.yml` に配置する必要があります。

### サポートされるタイプ

`active_record.encryption` は、暗号化する前に値を基になる型でシリアライズしますが、*文字列としてシリアライズ可能である必要があります*。 `serialized` のような構造化されたタイプは、デフォルトでサポートされています。

カスタムタイプをサポートする場合は、[serialized attribute](https://api.rubyonrails.org/classes/ActiveRecord/AttributeMethods/Serialization/ClassMethods.html) を使用することをお勧めします。シリアライズされた属性の宣言は、暗号化の宣言の**前**に配置する必要があります。

```ruby
# 正しい例
class Article < ApplicationRecord
  serialize :title, type: Title
  encrypts :title
end

# 間違った例
class Article < ApplicationRecord
  encrypts :title
  serialize :title, type: Title
end
```

### 大文字と小文字の区別を無視する

決定論的に暗号化されたデータをクエリする際には、大文字と小文字を無視する必要がある場合があります。これを容易にするために、2つのアプローチがあります：

暗号化属性の宣言時に `:downcase` オプションを使用して、暗号化前にコンテンツを小文字に変換することができます。

```ruby
class Person
  encrypts :email_address, deterministic: true, downcase: true
end
```

`:downcase` を使用すると、元の大文字と小文字の情報は失われます。一部の状況では、クエリ時に大文字と小文字を無視するだけでなく、元の大文字と小文字も保持したい場合があります。そのような場合には、オプション `:ignore_case` を使用します。これにより、大文字と小文字が変更されずにコンテンツを格納するために、`original_<column_name>` という名前の新しい列を追加する必要があります。

```ruby
class Label
  encrypts :name, deterministic: true, ignore_case: true # 元の大文字と小文字が変更されずにコンテンツが `original_name` 列に格納されます
end
```

### 暗号化されていないデータのサポート

暗号化されていないデータの移行を容易にするために、ライブラリには `config.active_record.encryption.support_unencrypted_data` オプションが含まれています。これを `true` に設定すると、次のような動作が行われます：

* 暗号化されていない属性を読み取ろうとすると、エラーが発生せずに通常通り動作します。
* 決定論的に暗号化された属性を含むクエリには、「クリアテキスト」バージョンも含まれ、暗号化されたコンテンツと暗号化されていないコンテンツの両方を検索できるようになります。これを有効にするには、`config.active_record.encryption.extend_queries = true` を設定する必要があります。

**このオプションは、クリアデータと暗号化されたデータが共存する移行期間に使用することを目的としています**。デフォルトでは、どちらも `false` に設定されており、アプリケーションの目標として推奨されます：暗号化されていないデータを処理する際にエラーが発生します。

### 以前の暗号化方式のサポート

属性の暗号化プロパティを変更すると、既存のデータが壊れる可能性があります。たとえば、決定論的な属性を非決定論的にする場合、モデルの宣言を変更するだけでは、既存の暗号文の読み取りが失敗します。なぜなら、暗号化方法が異なるからです。
これらの状況をサポートするために、2つのシナリオで使用される前の暗号化方式を宣言することができます。

* 暗号化されたデータを読み取る場合、Active Record Encryptionは現在の方式が機能しない場合に前の暗号化方式を試します。
* 決定論的データをクエリする場合、前の方式を使用して暗号文を追加し、異なる方式で暗号化されたデータとシームレスに動作するようにします。これを有効にするには、`config.active_record.encryption.extend_queries = true`を設定する必要があります。

前の暗号化方式を設定することができます：

* グローバルに
* 属性ごとに

#### グローバルな前の暗号化方式

`application.rb`で`previous`設定プロパティを使用して、前の暗号化方式をプロパティのリストとして追加することで、前の暗号化方式を追加できます。

```ruby
config.active_record.encryption.previous = [ { key_provider: MyOldKeyProvider.new } ]
```

#### 属性ごとの暗号化方式

属性を宣言する際に`：previous`を使用します。

```ruby
class Article
  encrypts :title, deterministic: true, previous: { deterministic: false }
end
```

#### 暗号化方式と決定論的属性

前の暗号化方式を追加する場合：

* **決定論的暗号化**の場合、新しい情報は常に*最新*（現在の）暗号化方式で暗号化されます。
* **非決定論的暗号化**の場合、新しい情報はデフォルトで常に*最古*の暗号化方式で暗号化されます。

通常、決定論的暗号化では、暗号文を一定に保ちたいと考えることが多いです。これを変更するには、`deterministic: { fixed: false }`を設定します。その場合、新しいデータの暗号化には*最新*の暗号化方式が使用されます。

### 一意の制約

注意：一意の制約は、決定論的に暗号化されたデータでのみ使用できます。

#### 一意の検証

一意の検証は、拡張クエリが有効になっている場合（`config.active_record.encryption.extend_queries = true`）、通常どおりサポートされます。

```ruby
class Person
  validates :email_address, uniqueness: true
  encrypts :email_address, deterministic: true, downcase: true
end
```

また、暗号化されたデータと非暗号化されたデータを組み合わせた場合や、前の暗号化方式を設定した場合でも機能します。

注意：大文字と小文字を区別しない場合は、`encrypts`宣言で`downcase:`または`ignore_case:`を使用する必要があります。検証で`case_sensitive:`オプションを使用すると機能しません。

#### 一意のインデックス

決定論的に暗号化された列の一意のインデックスをサポートするためには、その暗号文が常に変更されないようにする必要があります。

これを促すために、複数の暗号化方式が設定されている場合、決定論的属性はデフォルトで常に最も古い利用可能な暗号化方式を使用します。それ以外の場合、これらの属性の暗号化プロパティが変更されないようにするか、一意のインデックスは機能しません。

```ruby
class Person
  encrypts :email_address, deterministic: true
end
```

### 暗号化された列として名前付けられたフィルタリングパラメータ

デフォルトでは、暗号化された列は[Railsのログで自動的にフィルタリングされます](action_controller_overview.html#parameters-filtering)。これを無効にするには、`application.rb`に次の設定を追加します。

フィルタパラメータを生成する際に、モデル名を接頭辞として使用します。例：`Person#name`の場合、フィルタパラメータは`person.name`になります。

```ruby
config.active_record.encryption.add_to_filter_parameters = false
```

この自動フィルタリングから特定の列を除外する場合は、それらを`config.active_record.encryption.excluded_from_filter_parameters`に追加します。

### エンコーディング

文字列値が非決定的に暗号化された場合、ライブラリはエンコーディングを保持します。

エンコーディングは暗号化ペイロードとともに保存されるため、決定論的に暗号化された値はデフォルトでUTF-8エンコーディングを強制します。したがって、異なるエンコーディングを持つ同じ値は、暗号化すると異なる暗号文になります。クエリや一意の制約が機能するようにするためには、これを避けることが一般的です。そのため、ライブラリは自動的に変換を行います。

決定論的暗号化のデフォルトのエンコーディングを設定するには、次のようにします。

```ruby
config.active_record.encryption.forced_encoding_for_deterministic_encryption = Encoding::US_ASCII
```

また、この動作を無効にしてすべての場合でエンコーディングを保持するには、次のようにします。

```ruby
config.active_record.encryption.forced_encoding_for_deterministic_encryption = nil
```

## キー管理

キープロバイダはキー管理戦略を実装します。キープロバイダはグローバルにまたは属性ごとに設定できます。

### 組み込みキープロバイダ

#### DerivedSecretKeyProvider

提供されたパスワードを使用してPBKDF2を使用して派生キーを提供するキープロバイダです。

```ruby
config.active_record.encryption.key_provider = ActiveRecord::Encryption::DerivedSecretKeyProvider.new(["some passwords", "to derive keys from. ", "These should be in", "credentials"])
```

注意：デフォルトでは、`active_record.encryption`は`active_record.encryption.primary_key`で定義されたキーを使用して`DerivedSecretKeyProvider`を設定します。

#### EnvelopeEncryptionKeyProvider

シンプルな[封筒暗号化](https://docs.aws.amazon.com/kms/latest/developerguide/concepts.html#enveloping)戦略を実装します。

- データ暗号化操作ごとにランダムなキーを生成します
- データキーをデータ自体とともに保存し、クレデンシャル`active_record.encryption.primary_key`で暗号化します。

Active Recordをこのキープロバイダを使用するように設定するには、次のように`application.rb`に追加します。

```ruby
config.active_record.encryption.key_provider = ActiveRecord::Encryption::EnvelopeEncryptionKeyProvider.new
```

他の組み込みキープロバイダと同様に、キーローテーションスキームを実装するために`active_record.encryption.primary_key`に主キーのリストを指定できます。
### カスタムキープロバイダ

より高度なキー管理スキームに対応するために、初期化子でカスタムキープロバイダを設定できます。

```ruby
ActiveRecord::Encryption.key_provider = MyKeyProvider.new
```

キープロバイダはこのインターフェースを実装する必要があります。

```ruby
class MyKeyProvider
  def encryption_key
  end

  def decryption_keys(encrypted_message)
  end
end
```

両方のメソッドは`ActiveRecord::Encryption::Key`オブジェクトを返します。

- `encryption_key`は、一部のコンテンツの暗号化に使用されるキーを返します。
- `decryption_keys`は、指定されたメッセージを復号化するための潜在的なキーのリストを返します。

キーには、メッセージと一緒に暗号化されないで保存される任意のタグを含めることができます。復号化時にこれらの値を調べるために`ActiveRecord::Encryption::Message#headers`を使用できます。

### モデル固有のキープロバイダ

`key_provider`オプションを使用して、クラスごとにキープロバイダを設定できます。

```ruby
class Article < ApplicationRecord
  encrypts :summary, key_provider: ArticleKeyProvider.new
end
```

### モデル固有のキー

`key`オプションを使用して、特定のキーをクラスごとに設定できます。

```ruby
class Article < ApplicationRecord
  encrypts :summary, key: "記事の要約のための秘密のキー"
end
```

Active Recordは、データの暗号化と復号化に使用するキーを派生させるためにキーを使用します。

### キーのローテーション

`active_record.encryption`は、キーローテーションスキームの実装をサポートするためにキーのリストで動作できます。

- **最後のキー**は新しいコンテンツの暗号化に使用されます。
- コンテンツの復号化時には、すべてのキーが試され、一致するキーが見つかるまで続けられます。

```yml
active_record_encryption:
  primary_key:
    - a1cc4d7b9f420e40a337b9e68c5ecec6 # 以前のキーは既存のコンテンツを復号化できます
    - bc17e7b413fd4720716a7633027f8cc4 # アクティブで新しいコンテンツを暗号化します
  key_derivation_salt: a3226b97b3b2f8372d1fc6d497a0c0d3
```

これにより、新しいキーを追加し、コンテンツを再暗号化し、古いキーを削除することで、キーのリストを短く保つワークフローが可能になります。

注意：決定論的暗号化では、キーのローテーションは現在サポートされていません。

注意：Active Record Encryptionは、キーローテーションプロセスの自動管理をまだ提供していません。すべての要素は揃っていますが、まだ実装されていません。

### キーの参照の保存

`active_record.encryption.store_key_references`を設定すると、`active_record.encryption`は暗号化されたメッセージ自体に暗号化キーへの参照を保存します。

```ruby
config.active_record.encryption.store_key_references = true
```

これにより、システムはキーのリストを試す代わりに、キーを直接見つけることができるため、復号化がより高速になります。その代償として、暗号化されたデータは少し大きくなります。

## API

### 基本的なAPI

ActiveRecordの暗号化は宣言的に使用することを意図していますが、高度な使用シナリオのためにAPIも提供しています。

#### 暗号化と復号化

```ruby
article.encrypt # 暗号化または再暗号化する
article.decrypt # すべての暗号化可能な属性を復号化する
```

#### サイファーテキストの読み取り

```ruby
article.ciphertext_for(:title)
```

#### 属性が暗号化されているかどうかのチェック

```ruby
article.encrypted_attribute?(:title)
```

## 設定

### 設定オプション

Active Record Encryptionのオプションは、`application.rb`（最も一般的なシナリオ）または特定の環境設定ファイル`config/environments/<env name>.rb`で設定できます。環境ごとに設定する場合は、これらのオプションを使用します。

警告：キーを保存するためにRailsの組み込みのcredentialsサポートを使用することをお勧めします。設定プロパティを手動で設定する場合は、コードと一緒にコミットしないように注意してください（たとえば、環境変数を使用してください）。

#### `config.active_record.encryption.support_unencrypted_data`

trueの場合、暗号化されていないデータは通常通り読み取ることができます。falseの場合、エラーが発生します。デフォルト：`false`。

#### `config.active_record.encryption.extend_queries`

trueの場合、決定論的に暗号化された属性を参照するクエリは、必要に応じて追加の値を含めるように変更されます。これらの追加の値は、値のクリーンバージョン（`config.active_record.encryption.support_unencrypted_data`がtrueの場合）および以前の暗号化スキームで暗号化された値（`previous:`オプションで指定）です。デフォルト：`false`（実験的）。

#### `config.active_record.encryption.encrypt_fixtures`

trueの場合、フィクスチャの暗号化可能な属性は、ロード時に自動的に暗号化されます。デフォルト：`false`。

#### `config.active_record.encryption.store_key_references`

trueの場合、暗号化キーへの参照が暗号化されたメッセージのヘッダに保存されます。これにより、複数のキーが使用される場合に復号化が高速化されます。デフォルト：`false`。

#### `config.active_record.encryption.add_to_filter_parameters`

trueの場合、暗号化属性名が自動的に[`config.filter_parameters`][]に追加され、ログに表示されません。デフォルト：`true`。

#### `config.active_record.encryption.excluded_from_filter_parameters`

`config.active_record.encryption.add_to_filter_parameters`がtrueの場合にフィルタリングされないパラメータのリストを設定できます。デフォルト：`[]`。

#### `config.active_record.encryption.validate_column_size`

列サイズに基づいたバリデーションを追加します。これは、高度に圧縮可能なペイロードを使用して巨大な値を保存するのを防ぐために推奨されます。デフォルト：`true`。

#### `config.active_record.encryption.primary_key`

ルートデータ暗号化キーを派生させるために使用されるキーまたはキーのリスト。使用方法は設定されたキープロバイダによって異なります。`active_record_encryption.primary_key`クレデンシャルを使用して設定することを推奨します。
#### `config.active_record.encryption.deterministic_key`

決定論的暗号化に使用されるキーまたはキーのリストです。`active_record_encryption.deterministic_key`のクレデンシャルを介して設定することが推奨されています。

#### `config.active_record.encryption.key_derivation_salt`

キーを導出する際に使用されるソルトです。`active_record_encryption.key_derivation_salt`のクレデンシャルを介して設定することが推奨されています。

#### `config.active_record.encryption.forced_encoding_for_deterministic_encryption`

決定論的に暗号化された属性のデフォルトのエンコーディングです。このオプションを`nil`に設定することで強制エンコーディングを無効にすることができます。デフォルトでは`Encoding::UTF_8`です。

#### `config.active_record.encryption.hash_digest_class`

キーを導出するために使用されるダイジェストアルゴリズムです。デフォルトでは`OpenSSL::Digest::SHA1`です。

#### `config.active_record.encryption.support_sha1_for_non_deterministic_encryption`

SHA1のダイジェストクラスで非決定論的に暗号化されたデータの復号をサポートします。デフォルトはfalseであり、`config.active_record.encryption.hash_digest_class`で設定されたダイジェストアルゴリズムのみをサポートします。

### 暗号化コンテキスト

暗号化コンテキストは、特定の瞬間に使用される暗号化コンポーネントを定義します。グローバルな設定に基づいたデフォルトの暗号化コンテキストがありますが、属性ごとにカスタムコンテキストを設定したり、特定のコードブロックを実行する際にカスタムコンテキストを設定したりすることができます。

注意：暗号化コンテキストは柔軟ながらも高度な設定メカニズムです。ほとんどのユーザーはこれについて心配する必要はありません。

暗号化コンテキストの主なコンポーネントは次のとおりです：

* `encryptor`：データを暗号化および復号化するための内部APIを公開します。`key_provider`と連携して暗号化されたメッセージを構築し、そのシリアライズを処理します。暗号化/復号化自体は`cipher`によって行われ、シリアライズは`message_serializer`によって行われます。
* `cipher`：暗号化アルゴリズム自体（AES 256 GCM）
* `key_provider`：暗号化および復号化キーを提供します。
* `message_serializer`：暗号化されたペイロード（`Message`）をシリアライズおよびデシリアライズします。

注意：独自の`message_serializer`を作成する場合は、任意のオブジェクトをデシリアライズできない安全なメカニズムを使用することが重要です。一般的にサポートされているシナリオは、既存の非暗号化データを暗号化することです。攻撃者はこれを利用して、暗号化が行われる前に改ざんされたペイロードを入力し、RCE攻撃を実行することができます。したがって、カスタムシリアライザは`Marshal`、`YAML.load`（代わりに`YAML.safe_load`を使用）、または`JSON.load`（代わりに`JSON.parse`を使用）を避けるべきです。

#### グローバルな暗号化コンテキスト

グローバルな暗号化コンテキストはデフォルトで使用され、`application.rb`または環境設定ファイルで他の設定プロパティと同様に設定されます。

```ruby
config.active_record.encryption.key_provider = ActiveRecord::Encryption::EnvelopeEncryptionKeyProvider.new
config.active_record.encryption.encryptor = MyEncryptor.new
```

#### 属性ごとの暗号化コンテキスト

属性の宣言時にパラメータを渡すことで、暗号化コンテキストのパラメータをオーバーライドすることができます。

```ruby
class Attribute
  encrypts :title, encryptor: MyAttributeEncryptor.new
end
```

#### コードブロックを実行する際の暗号化コンテキスト

`ActiveRecord::Encryption.with_encryption_context`を使用して、特定のコードブロックに対して暗号化コンテキストを設定することができます。

```ruby
ActiveRecord::Encryption.with_encryption_context(encryptor: ActiveRecord::Encryption::NullEncryptor.new) do
  ...
end
```

#### 組み込みの暗号化コンテキスト

##### 暗号化の無効化

暗号化なしでコードを実行することができます。

```ruby
ActiveRecord::Encryption.without_encryption do
   ...
end
```

これにより、暗号化されたテキストの読み取りは暗号文を返し、保存されたコンテンツは非暗号化で保存されます。

##### 暗号化データの保護

暗号化なしでコードを実行しますが、暗号化されたコンテンツの上書きを防止します。

```ruby
ActiveRecord::Encryption.protecting_encrypted_data do
   ...
end
```

これは、暗号化されたデータを保護しながら任意のコードを実行する場合に便利です（例：Railsコンソールでの実行）。
[`config.filter_parameters`]: configuring.html#config-filter-parameters
