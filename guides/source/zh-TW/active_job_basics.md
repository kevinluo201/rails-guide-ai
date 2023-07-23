**DO NOT READ THIS FILE ON GITHUB, GUIDES ARE PUBLISHED ON https://guides.rubyonrails.org.**, original file md5: 8e409a33cc6caed27c82b91e6adad6c7
Active Job 基礎
=================

本指南提供了一切你需要開始創建、排隊和執行背景工作的資訊。

閱讀完本指南後，你將會知道：

* 如何創建工作。
* 如何排隊工作。
* 如何在背景中執行工作。
* 如何從你的應用程式中異步發送郵件。

--------------------------------------------------------------------------------

什麼是 Active Job？
-------------------

Active Job 是一個聲明工作並使其在各種排隊後端上運行的框架。這些工作可以是定期排程的清理、計費收費或郵件發送等等。實際上，任何可以被分解成小單位並且可以並行運行的工作都可以使用 Active Job。

Active Job 的目的
-----------------------------

主要目的是確保所有的 Rails 應用程式都有一個工作基礎架構。這樣，我們就可以在其上建立框架功能和其他寶石，而不必擔心不同工作運行器（如 Delayed Job 和 Resque）之間的 API 差異。選擇排隊後端變成了一個操作上的考慮，你可以在不重寫工作的情況下切換它們。

注意：Rails 預設提供了一個異步排隊實現，它使用一個進程內的執行緒池來運行工作。工作將以異步方式運行，但在重新啟動時，任何在排隊中的工作都將被丟棄。

創建一個工作
--------------

本節將提供一個逐步指南來創建一個工作並將其排隊。

### 創建工作

Active Job 提供了一個 Rails 生成器來創建工作。以下命令將在 `app/jobs` 中創建一個工作（並在 `test/jobs` 下創建一個相應的測試案例）：

```bash
$ bin/rails generate job guests_cleanup
invoke  test_unit
create    test/jobs/guests_cleanup_job_test.rb
create  app/jobs/guests_cleanup_job.rb
```

你也可以創建一個在特定排隊中運行的工作：

```bash
$ bin/rails generate job guests_cleanup --queue urgent
```

如果你不想使用生成器，你可以在 `app/jobs` 中創建自己的文件，只需確保它繼承自 `ApplicationJob`。

以下是一個工作的範例：

```ruby
class GuestsCleanupJob < ApplicationJob
  queue_as :default

  def perform(*guests)
    # 執行某些操作
  end
end
```

請注意，你可以定義 `perform` 方法帶有任意數量的參數。

如果你已經有一個抽象類，並且它的名稱與 `ApplicationJob` 不同，你可以使用 `--parent` 選項來指定你想要一個不同的抽象類：

```bash
$ bin/rails generate job process_payment --parent=payment_job
```

```ruby
class ProcessPaymentJob < PaymentJob
  queue_as :default

  def perform(*args)
    # 執行某些操作
  end
end
```

### 將工作排隊

使用 [`perform_later`][] 和（可選）[`set`][] 將工作排隊。例如：

```ruby
# 將一個工作排隊，以便在排隊系統空閒時立即執行。
GuestsCleanupJob.perform_later guest
```

```ruby
# 將一個工作排隊，以便在明天中午執行。
GuestsCleanupJob.set(wait_until: Date.tomorrow.noon).perform_later(guest)
```

```ruby
# 將一個工作排隊，以便在一周後執行。
GuestsCleanupJob.set(wait: 1.week).perform_later(guest)
```

```ruby
# `perform_now` 和 `perform_later` 會在底層調用 `perform`，所以你可以傳遞與後者中定義的參數數量相同的參數。
GuestsCleanupJob.perform_later(guest1, guest2, filter: 'some_filter')
```

就是這樣！

工作執行
-------------

要在生產環境中排隊和執行工作，你需要設置一個排隊後端，也就是說，你需要選擇一個 Rails 應該使用的第三方排隊庫。Rails 本身只提供了一個進程內的排隊系統，它只將工作保存在 RAM 中。如果進程崩潰或機器重啟，則所有未完成的工作都會丟失。這對於較小的應用程式或非關鍵性的工作可能沒有問題，但大多數生產應用程式需要選擇一個持久的後端。

### 後端

Active Job 內建了多個排隊後端的適配器（如 Sidekiq、Resque、Delayed Job 等）。要獲取最新的適配器列表，請參閱 [`ActiveJob::QueueAdapters`][] 的 API 文件。

### 設置後端

你可以使用 [`config.active_job.queue_adapter`] 輕鬆設置你的排隊後端：

```ruby
# config/application.rb
module YourApp
  class Application < Rails::Application
    # 確保在你的 Gemfile 中有適配器的 gem，
    # 並遵循適配器的特定安裝和部署說明。
    config.active_job.queue_adapter = :sidekiq
  end
end
```

你也可以根據每個工作單獨配置你的後端：

```ruby
class GuestsCleanupJob < ApplicationJob
  self.queue_adapter = :resque
  # ...
end

# 現在你的工作將使用 `resque` 作為其後端排隊適配器，覆蓋了在 `config.active_job.queue_adapter` 中配置的設置。
```
### 啟動後端

由於作業在Rails應用程式中並行執行，大多數佇列庫需要您啟動特定於該庫的佇列服務（除了啟動Rails應用程式）以使作業處理正常運作。請參閱庫的文件以獲取有關啟動佇列後端的指示。

這是一份非全面性的文件列表：

- [Sidekiq](https://github.com/mperham/sidekiq/wiki/Active-Job)
- [Resque](https://github.com/resque/resque/wiki/ActiveJob)
- [Sneakers](https://github.com/jondot/sneakers/wiki/How-To:-Rails-Background-Jobs-with-ActiveJob)
- [Sucker Punch](https://github.com/brandonhilkert/sucker_punch#active-job)
- [Queue Classic](https://github.com/QueueClassic/queue_classic#active-job)
- [Delayed Job](https://github.com/collectiveidea/delayed_job#active-job)
- [Que](https://github.com/que-rb/que#additional-rails-specific-setup)
- [Good Job](https://github.com/bensheldon/good_job#readme)

佇列
------

大多數適配器支援多個佇列。使用Active Job，您可以使用[`queue_as`][]來安排作業在特定佇列上運行：

```ruby
class GuestsCleanupJob < ApplicationJob
  queue_as :low_priority
  # ...
end
```

您可以使用[`config.active_job.queue_name_prefix`][]在`application.rb`中為所有作業的佇列名稱添加前綴：

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

# 現在，您的作業將在生產環境的production_low_priority佇列上運行，
# 並在暫存環境的staging_low_priority佇列上運行
```

您還可以根據每個作業單獨配置前綴。

```ruby
class GuestsCleanupJob < ApplicationJob
  queue_as :low_priority
  self.queue_name_prefix = nil
  # ...
end

# 現在，您的作業的佇列名稱將不帶前綴，覆蓋了在`config.active_job.queue_name_prefix`中配置的內容。
```

默認的佇列名稱前綴分隔符是'\_'。您可以通過在`application.rb`中設置[`config.active_job.queue_name_delimiter`][]來更改它：

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

# 現在，您的作業將在生產環境的production.low_priority佇列上運行，
# 並在暫存環境的staging.low_priority佇列上運行
```

如果您想更精確地控制作業將在哪個佇列上運行，可以將`：queue`選項傳遞給`set`：

```ruby
MyJob.set(queue: :another_queue).perform_later(record)
```

要從作業層面控制佇列，可以將塊傳遞給`queue_as`。該塊將在作業上下文中執行（因此可以訪問`self.arguments`），並且必須返回佇列名稱：

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
    # 執行視頻處理
  end
end
```

```ruby
ProcessVideoJob.perform_later(Video.last)
```

注意：請確保您的佇列後端“監聽”您的佇列名稱。對於某些後端，您需要指定要監聽的佇列。


回調
---------

Active Job提供了在作業生命週期中觸發邏輯的鉤子。與Rails中的其他回調一樣，您可以將回調實現為普通方法，並使用宏風格的類方法將它們註冊為回調：

```ruby
class GuestsCleanupJob < ApplicationJob
  queue_as :default

  around_perform :around_cleanup

  def perform
    # 執行某些操作
  end

  private
    def around_cleanup
      # 在執行之前執行某些操作
      yield
      # 在執行之後執行某些操作
    end
end
```

宏風格的類方法也可以接收一個塊。如果您的塊內的代碼非常簡短，可以使用此風格。例如，您可以為每個入隊的作業發送指標：

```ruby
class ApplicationJob < ActiveJob::Base
  before_enqueue { |job| $statsd.increment "#{job.class.name.underscore}.enqueue" }
end
```

### 可用的回調

* [`before_enqueue`][]
* [`around_enqueue`][]
* [`after_enqueue`][]
* [`before_perform`][]
* [`around_perform`][]
* [`after_perform`][]


動作郵件
------------

在現代Web應用程序中，最常見的工作之一是在請求-響應週期之外發送電子郵件，以便用戶無需等待。Active Job與Action Mailer集成，因此您可以輕鬆地異步發送電子郵件：

```ruby
# 如果要立即發送電子郵件，請使用#deliver_now
UserMailer.welcome(@user).deliver_now

# 如果要通過Active Job發送電子郵件，請使用#deliver_later
UserMailer.welcome(@user).deliver_later
```

注意：從Rake任務使用異步佇列（例如，使用`.deliver_later`發送電子郵件）通常不起作用，因為Rake可能會在任何/所有`.deliver_later`電子郵件處理之前結束，導致在處理之前刪除處理中的線程池。為了避免此問題，在開發中使用`.deliver_now`或運行持久佇列。


國際化
--------------------

每個作業使用創建作業時設置的`I18n.locale`。如果您異步發送電子郵件，這很有用：

```ruby
I18n.locale = :eo

UserMailer.welcome(@user).deliver_later # 電子郵件將以世界語本地化。
```


支持的參數類型
----------------------------
ActiveJob 支援以下預設的參數類型：

  - 基本類型（`NilClass`、`String`、`Integer`、`Float`、`BigDecimal`、`TrueClass`、`FalseClass`）
  - `Symbol`
  - `Date`
  - `Time`
  - `DateTime`
  - `ActiveSupport::TimeWithZone`
  - `ActiveSupport::Duration`
  - `Hash`（鍵應該是 `String` 或 `Symbol` 類型）
  - `ActiveSupport::HashWithIndifferentAccess`
  - `Array`
  - `Range`
  - `Module`
  - `Class`

### GlobalID

Active Job 支援 [GlobalID](https://github.com/rails/globalid/blob/master/README.md) 作為參數。這使得您可以將活動的 Active Record 物件傳遞給工作，而不是類別/ID 對，然後您需要手動反序列化。以前，工作會像這樣：

```ruby
class TrashableCleanupJob < ApplicationJob
  def perform(trashable_class, trashable_id, depth)
    trashable = trashable_class.constantize.find(trashable_id)
    trashable.cleanup(depth)
  end
end
```

現在您可以簡單地這樣做：

```ruby
class TrashableCleanupJob < ApplicationJob
  def perform(trashable, depth)
    trashable.cleanup(depth)
  end
end
```

這適用於任何混入 `GlobalID::Identification` 的類別，預設已混入 Active Record 類別。

### 序列化器

您可以擴展支援的參數類型列表。您只需要定義自己的序列化器：

```ruby
# app/serializers/money_serializer.rb
class MoneySerializer < ActiveJob::Serializers::ObjectSerializer
  # 檢查參數是否應由此序列化器序列化。
  def serialize?(argument)
    argument.is_a? Money
  end

  # 使用支援的物件類型將物件轉換為較簡單的表示形式。
  # 推薦的表示形式是具有特定鍵的 Hash。鍵只能是基本類型。
  # 您應該調用 `super` 將自訂的序列化器類型添加到哈希中。
  def serialize(money)
    super(
      "amount" => money.amount,
      "currency" => money.currency
    )
  end

  # 將序列化的值轉換為正確的物件。
  def deserialize(hash)
    Money.new(hash["amount"], hash["currency"])
  end
end
```

並將此序列化器添加到列表中：

```ruby
# config/initializers/custom_serializers.rb
Rails.application.config.active_job.custom_serializers << MoneySerializer
```

請注意，初始化期間不支援重新載入可重新載入的程式碼。因此，建議僅加載一次序列化器，例如通過修改 `config/application.rb` 如下：

```ruby
# config/application.rb
module YourApp
  class Application < Rails::Application
    config.autoload_once_paths << Rails.root.join('app', 'serializers')
  end
end
```

例外狀況
----------

在工作執行期間引發的例外狀況可以使用 [`rescue_from`][] 來處理：

```ruby
class GuestsCleanupJob < ApplicationJob
  queue_as :default

  rescue_from(ActiveRecord::RecordNotFound) do |exception|
    # 處理例外狀況
  end

  def perform
    # 執行某些操作
  end
end
```

如果工作的例外狀況未被捕獲，則該工作被稱為「失敗」。

### 重試或丟棄失敗的工作

除非另有配置，否則失敗的工作不會重試。

可以使用 [`retry_on`] 或 [`discard_on`] 來重試或丟棄失敗的工作。例如：

```ruby
class RemoteServiceJob < ApplicationJob
  retry_on CustomAppException # 預設為 3 秒等待，5 次嘗試

  discard_on ActiveJob::DeserializationError

  def perform(*args)
    # 可能會引發 CustomAppException 或 ActiveJob::DeserializationError
  end
end
```


### 反序列化

GlobalID 允許序列化傳遞給 `#perform` 的完整 Active Record 物件。

如果在工作入隊之後但在調用 `#perform` 方法之前，傳遞的記錄被刪除，Active Job 將引發 [`ActiveJob::DeserializationError`][] 例外狀況。


工作測試
--------------

您可以在[測試指南](testing.html#testing-jobs)中找到有關如何測試工作的詳細說明。

除錯
---------

如果您需要幫助找出工作來自何處，您可以啟用[詳細日誌記錄](debugging_rails_applications.html#verbose-enqueue-logs)。
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
