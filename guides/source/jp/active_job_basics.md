**DO NOT READ THIS FILE ON GITHUB, GUIDES ARE PUBLISHED ON https://guides.rubyonrails.org.**, original file md5: 8e409a33cc6caed27c82b91e6adad6c7
Active Jobの基本
=================

このガイドでは、バックグラウンドジョブの作成、エンキュー、実行を開始するために必要なすべての情報を提供します。

このガイドを読み終えると、以下のことがわかります。

* ジョブの作成方法
* ジョブのエンキュー方法
* バックグラウンドでジョブを実行する方法
* アプリケーションから非同期にメールを送信する方法

--------------------------------------------------------------------------------

Active Jobとは？
-------------------

Active Jobは、ジョブを宣言し、さまざまなキューイングバックエンドで実行するためのフレームワークです。これらのジョブは、定期的なスケジュールされたクリーンアップ、請求料金、メーリングなど、さまざまなものです。実際には、小さな作業単位に分割して並列に実行できるものです。

Active Jobの目的
-----------------------------

主な目的は、すべてのRailsアプリにジョブインフラストラクチャが備わっていることを保証することです。その上にフレームワークの機能や他のgemを構築できるようにすることで、Delayed JobやResqueなどのさまざまなジョブランナー間のAPIの違いを気にする必要がなくなります。キューイングバックエンドの選択は、運用上の問題になります。ジョブを書き直すことなくそれらの間を切り替えることができます。

注意：Railsにはデフォルトで非同期キューイングの実装があり、ジョブはインプロセスのスレッドプールで実行されます。ジョブは非同期に実行されますが、キューにあるジョブは再起動時に破棄されます。


ジョブの作成
--------------

このセクションでは、ジョブの作成とエンキューの手順についてのステップバイステップのガイドを提供します。

### ジョブの作成

Active Jobは、ジョブを作成するためのRailsジェネレータを提供しています。以下のコマンドを実行すると、`app/jobs`にジョブが作成されます（`test/jobs`にはテストケースが作成されます）。

```bash
$ bin/rails generate job guests_cleanup
invoke  test_unit
create    test/jobs/guests_cleanup_job_test.rb
create  app/jobs/guests_cleanup_job.rb
```

特定のキューで実行されるジョブも作成できます。

```bash
$ bin/rails generate job guests_cleanup --queue urgent
```

ジェネレータを使用しない場合は、`app/jobs`内に独自のファイルを作成することもできますが、`ApplicationJob`から継承していることを確認してください。

ジョブの例は以下のようになります。

```ruby
class GuestsCleanupJob < ApplicationJob
  queue_as :default

  def perform(*guests)
    # 何かしらの処理
  end
end
```

`perform`メソッドには任意の数の引数を定義できることに注意してください。

もし既に抽象クラスがあり、その名前が`ApplicationJob`と異なる場合は、`--parent`オプションを渡して別の抽象クラスを指定することができます。

```bash
$ bin/rails generate job process_payment --parent=payment_job
```

```ruby
class ProcessPaymentJob < PaymentJob
  queue_as :default

  def perform(*args)
    # 何かしらの処理
  end
end
```

### ジョブのエンキュー

[`perform_later`][]と、必要に応じて[`set`][]を使用してジョブをエンキューします。

```ruby
# キューが空くとすぐに実行されるようにジョブをエンキューします。
GuestsCleanupJob.perform_later guest
```

```ruby
# 明日の正午に実行されるようにジョブをエンキューします。
GuestsCleanupJob.set(wait_until: Date.tomorrow.noon).perform_later(guest)
```

```ruby
# 1週間後に実行されるようにジョブをエンキューします。
GuestsCleanupJob.set(wait: 1.week).perform_later(guest)
```

```ruby
# `perform_now`と`perform_later`は内部で`perform`を呼び出すため、
# 後者で定義されている引数の数だけ引数を渡すことができます。
GuestsCleanupJob.perform_later(guest1, guest2, filter: 'some_filter')
```

以上です！


ジョブの実行
-------------

ジョブをエンキューして実行するためには、プロダクション環境でキューイングバックエンドを設定する必要があります。つまり、Railsが使用するサードパーティのキューイングライブラリを決定する必要があります。Rails自体はインプロセスのキューイングシステムしか提供しておらず、ジョブはすべてRAMに保持されます。プロセスがクラッシュしたり、マシンがリセットされた場合、デフォルトの非同期バックエンドではすべてのジョブが失われます。これは、小規模なアプリや重要でないジョブには問題ありませんが、ほとんどのプロダクションアプリでは永続的なバックエンドを選択する必要があります。

### バックエンド

Active Jobには、複数のキューイングバックエンド（Sidekiq、Resque、Delayed Jobなど）の組み込みアダプタがあります。アダプタの最新のリストについては、[`ActiveJob::QueueAdapters`][]のAPIドキュメントを参照してください。


### バックエンドの設定

[`config.active_job.queue_adapter`]を使用して簡単にキューイングバックエンドを設定できます。

```ruby
# config/application.rb
module YourApp
  class Application < Rails::Application
    # アダプタのgemがGemfileにあることを確認し、
    # アダプタの特定のインストールとデプロイ手順に従ってください。
    config.active_job.queue_adapter = :sidekiq
  end
end
```

ジョブごとにバックエンドを設定することもできます。

```ruby
class GuestsCleanupJob < ApplicationJob
  self.queue_adapter = :resque
  # ...
end

# これでジョブは、`config.active_job.queue_adapter`で設定されたものを上書きして、
# `resque`をバックエンドキューアダプタとして使用します。
```
### バックエンドの開始

ジョブはRailsアプリケーションと並行して実行されるため、ほとんどのキューイングライブラリは、ジョブ処理が機能するために、Railsアプリケーションの起動に加えて、ライブラリ固有のキューイングサービスを開始する必要があります。キューバックエンドの起動方法については、ライブラリのドキュメントを参照してください。

以下は、非包括的なドキュメントのリストです：

- [Sidekiq](https://github.com/mperham/sidekiq/wiki/Active-Job)
- [Resque](https://github.com/resque/resque/wiki/ActiveJob)
- [Sneakers](https://github.com/jondot/sneakers/wiki/How-To:-Rails-Background-Jobs-with-ActiveJob)
- [Sucker Punch](https://github.com/brandonhilkert/sucker_punch#active-job)
- [Queue Classic](https://github.com/QueueClassic/queue_classic#active-job)
- [Delayed Job](https://github.com/collectiveidea/delayed_job#active-job)
- [Que](https://github.com/que-rb/que#additional-rails-specific-setup)
- [Good Job](https://github.com/bensheldon/good_job#readme)

キュー
------

ほとんどのアダプタは複数のキューをサポートしています。Active Jobでは、[`queue_as`][]を使用してジョブを特定のキューで実行するようにスケジュールできます。

```ruby
class GuestsCleanupJob < ApplicationJob
  queue_as :low_priority
  # ...
end
```

すべてのジョブのキュー名にプレフィックスを付けるには、`application.rb`で[`config.active_job.queue_name_prefix`][]を使用します。

```ruby
# config/application.rb
module YourApp
  class Application < Rails::Application
    config.active_job.queue_name_prefix = Rails.env
  end
end
```

```ruby
# app/jobs/guests_cleanup_job.rb
class GuestsCleanupJob < ApplicationJob
  queue_as :low_priority
  # ...
end

# これで、ジョブは本番環境のproduction_low_priorityキューで実行され、ステージング環境のstaging_low_priorityキューで実行されます。
```

プレフィックスはジョブごとに個別に設定することもできます。

```ruby
class GuestsCleanupJob < ApplicationJob
  queue_as :low_priority
  self.queue_name_prefix = nil
  # ...
end

# これで、ジョブのキュー名にはプレフィックスが付かず、`config.active_job.queue_name_prefix`で設定された内容を上書きします。
```

デフォルトのキュー名のプレフィックス区切り文字は「\_」です。これは、`application.rb`で[`config.active_job.queue_name_delimiter`][]を設定することで変更できます。

```ruby
# config/application.rb
module YourApp
  class Application < Rails::Application
    config.active_job.queue_name_prefix = Rails.env
    config.active_job.queue_name_delimiter = '.'
  end
end
```

```ruby
# app/jobs/guests_cleanup_job.rb
class GuestsCleanupJob < ApplicationJob
  queue_as :low_priority
  # ...
end

# これで、ジョブは本番環境のproduction.low_priorityキューで実行され、ステージング環境のstaging.low_priorityキューで実行されます。
```

ジョブが実行されるキューをより細かく制御するには、`set`に`:queue`オプションを渡すことができます。

```ruby
MyJob.set(queue: :another_queue).perform_later(record)
```

ジョブレベルでキューを制御するには、`queue_as`にブロックを渡すこともできます。ブロックはジョブコンテキストで実行されるため（`self.arguments`にアクセスできる）、キュー名を返す必要があります。

```ruby
class ProcessVideoJob < ApplicationJob
  queue_as do
    video = self.arguments.first
    if video.owner.premium?
      :premium_videojobs
    else
      :videojobs
    end
  end

  def perform(video)
    # 動画の処理を行う
  end
end
```

```ruby
ProcessVideoJob.perform_later(Video.last)
```

注意：キューイングバックエンドが指定したキュー名を「リッスン」できるようにしてください。一部のバックエンドでは、リッスンするキューを指定する必要があります。


コールバック
---------

Active Jobは、ジョブのライフサイクル中にロジックをトリガーするためのフックを提供します。Railsの他のコールバックと同様に、コールバックを通常のメソッドとして実装し、マクロスタイルのクラスメソッドを使用してそれらをコールバックとして登録できます。

```ruby
class GuestsCleanupJob < ApplicationJob
  queue_as :default

  around_perform :around_cleanup

  def perform
    # 後で何かを行う
  end

  private
    def around_cleanup
      # performの前に何かを行う
      yield
      # performの後に何かを行う
    end
end
```

マクロスタイルのクラスメソッドは、ブロックを受け取ることもできます。ブロック内のコードが1行に収まるほど短い場合は、このスタイルを使用することを検討してください。たとえば、すべてのジョブがエンキューされるたびにメトリクスを送信できます。

```ruby
class ApplicationJob < ActiveJob::Base
  before_enqueue { |job| $statsd.increment "#{job.class.name.underscore}.enqueue" }
end
```

### 利用可能なコールバック

* [`before_enqueue`][]
* [`around_enqueue`][]
* [`after_enqueue`][]
* [`before_perform`][]
* [`around_perform`][]
* [`after_perform`][]


アクションメーラー
------------

モダンなWebアプリケーションで最も一般的なジョブの1つは、リクエスト-レスポンスのサイクル外でメールを送信することです。これにより、ユーザーは待つ必要がありません。Active JobはAction Mailerと統合されているため、簡単に非同期にメールを送信できます。

```ruby
# メールを即時に送信する場合は#deliver_nowを使用します
UserMailer.welcome(@user).deliver_now

# Active Jobを介してメールを送信する場合は#deliver_laterを使用します
UserMailer.welcome(@user).deliver_later
```

注意：非同期キューをRakeタスクから使用する場合（たとえば、`.deliver_later`を使用してメールを送信する場合）、一般的にはうまく動作しません。Rakeが終了する前に、`.deliver_later`のメールがすべて処理される前に、インプロセスのスレッドプールが削除される可能性があります。この問題を回避するためには、`.deliver_now`を使用するか、開発環境で永続的なキューを実行してください。


国際化
--------------------

各ジョブは、ジョブが作成されたときに設定された`I18n.locale`を使用します。これは、メールを非同期に送信する場合に便利です。

```ruby
I18n.locale = :eo

UserMailer.welcome(@user).deliver_later # メールはエスペラント語にローカライズされます。
```


引数のサポートされるタイプ
----------------------------
ActiveJobはデフォルトで以下のタイプの引数をサポートしています：

  - 基本的なタイプ（`NilClass`、`String`、`Integer`、`Float`、`BigDecimal`、`TrueClass`、`FalseClass`）
  - `Symbol`
  - `Date`
  - `Time`
  - `DateTime`
  - `ActiveSupport::TimeWithZone`
  - `ActiveSupport::Duration`
  - `Hash`（キーは`String`または`Symbol`のタイプである必要があります）
  - `ActiveSupport::HashWithIndifferentAccess`
  - `Array`
  - `Range`
  - `Module`
  - `Class`

### GlobalID

Active Jobはパラメータに[GlobalID](https://github.com/rails/globalid/blob/master/README.md)をサポートしています。これにより、クラス/IDのペアではなく、ライブなActive Recordオブジェクトをジョブに渡すことができます。これまでは、ジョブは次のようになっていました：

```ruby
class TrashableCleanupJob < ApplicationJob
  def perform(trashable_class, trashable_id, depth)
    trashable = trashable_class.constantize.find(trashable_id)
    trashable.cleanup(depth)
  end
end
```

これからは、次のように簡単にできます：

```ruby
class TrashableCleanupJob < ApplicationJob
  def perform(trashable, depth)
    trashable.cleanup(depth)
  end
end
```

これは、デフォルトでActive Recordクラスに混入されている`GlobalID::Identification`をミックスインする任意のクラスで機能します。

### シリアライザ

サポートされる引数のタイプを拡張することができます。独自のシリアライザを定義するだけです：

```ruby
# app/serializers/money_serializer.rb
class MoneySerializer < ActiveJob::Serializers::ObjectSerializer
  # このシリアライザで引数をシリアライズする必要があるかどうかをチェックします。
  def serialize?(argument)
    argument.is_a? Money
  end

  # サポートされるオブジェクトタイプを使用して、オブジェクトをよりシンプルな表現に変換します。
  # 推奨される表現は、特定のキーを持つハッシュです。キーは基本的なタイプのみにする必要があります。
  # カスタムシリアライザタイプをハッシュに追加するために`super`を呼び出す必要があります。
  def serialize(money)
    super(
      "amount" => money.amount,
      "currency" => money.currency
    )
  end

  # シリアライズされた値を適切なオブジェクトに変換します。
  def deserialize(hash)
    Money.new(hash["amount"], hash["currency"])
  end
end
```

そして、このシリアライザをリストに追加します：

```ruby
# config/initializers/custom_serializers.rb
Rails.application.config.active_job.custom_serializers << MoneySerializer
```

注意：初期化中にリロード可能なコードの自動読み込みはサポートされていません。したがって、シリアライザを1回だけロードされるように設定することをお勧めします。たとえば、次のように`config/application.rb`を修正することができます：

```ruby
# config/application.rb
module YourApp
  class Application < Rails::Application
    config.autoload_once_paths << Rails.root.join('app', 'serializers')
  end
end
```

例外
----------

ジョブの実行中に発生した例外は、[`rescue_from`][]を使用して処理することができます：

```ruby
class GuestsCleanupJob < ApplicationJob
  queue_as :default

  rescue_from(ActiveRecord::RecordNotFound) do |exception|
    # 例外を処理する
  end

  def perform
    # 何かを後で実行する
  end
end
```

ジョブからの例外が救出されない場合、ジョブは「失敗した」とみなされます。


### 失敗したジョブの再試行または破棄

失敗したジョブは、別の設定がない限り再試行されません。

[`retry_on`]または[`discard_on`]を使用して、失敗したジョブを再試行または破棄することができます。例：

```ruby
class RemoteServiceJob < ApplicationJob
  retry_on CustomAppException # デフォルトでは3秒待機、5回の試行

  discard_on ActiveJob::DeserializationError

  def perform(*args)
    # CustomAppExceptionまたはActiveJob::DeserializationErrorが発生する可能性があります
  end
end
```


### デシリアライズ

GlobalIDを使用すると、`#perform`に渡された完全なActive Recordオブジェクトをシリアライズすることができます。

ジョブがエンキューされた後で`#perform`メソッドが呼び出される前に、渡されたレコードが削除されると、Active Jobは[`ActiveJob::DeserializationError`][]例外を発生させます。


ジョブのテスト
--------------

ジョブをテストする方法の詳細な手順については、[テストガイド](testing.html#testing-jobs)を参照してください。

デバッグ
---------

ジョブの出所を特定するのに役立つ場合は、[詳細なログ出力](debugging_rails_applications.html#verbose-enqueue-logs)を有効にすることができます。
[`perform_later`]: https://api.rubyonrails.org/classes/ActiveJob/Enqueuing/ClassMethods.html#method-i-perform_later
[`set`]: https://api.rubyonrails.org/classes/ActiveJob/Core/ClassMethods.html#method-i-set
[`ActiveJob::QueueAdapters`]: https://api.rubyonrails.org/classes/ActiveJob/QueueAdapters.html
[`config.active_job.queue_adapter`]: configuring.html#config-active-job-queue-adapter
[`config.active_job.queue_name_delimiter`]: configuring.html#config-active-job-queue-name-delimiter
[`config.active_job.queue_name_prefix`]: configuring.html#config-active-job-queue-name-prefix
[`queue_as`]: https://api.rubyonrails.org/classes/ActiveJob/QueueName/ClassMethods.html#method-i-queue_as
[`before_enqueue`]: https://api.rubyonrails.org/classes/ActiveJob/Callbacks/ClassMethods.html#method-i-before_enqueue
[`around_enqueue`]: https://api.rubyonrails.org/classes/ActiveJob/Callbacks/ClassMethods.html#method-i-around_enqueue
[`after_enqueue`]: https://api.rubyonrails.org/classes/ActiveJob/Callbacks/ClassMethods.html#method-i-after_enqueue
[`before_perform`]: https://api.rubyonrails.org/classes/ActiveJob/Callbacks/ClassMethods.html#method-i-before_perform
[`around_perform`]: https://api.rubyonrails.org/classes/ActiveJob/Callbacks/ClassMethods.html#method-i-around_perform
[`after_perform`]: https://api.rubyonrails.org/classes/ActiveJob/Callbacks/ClassMethods.html#method-i-after_perform
[`rescue_from`]: https://api.rubyonrails.org/classes/ActiveSupport/Rescuable/ClassMethods.html#method-i-rescue_from
[`discard_on`]: https://api.rubyonrails.org/classes/ActiveJob/Exceptions/ClassMethods.html#method-i-discard_on
[`retry_on`]: https://api.rubyonrails.org/classes/ActiveJob/Exceptions/ClassMethods.html#method-i-retry_on
[`ActiveJob::DeserializationError`]: https://api.rubyonrails.org/classes/ActiveJob/DeserializationError.html
